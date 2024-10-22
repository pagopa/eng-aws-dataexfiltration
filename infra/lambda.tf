data "archive_file" "lambda_proxy" {
  type        = "zip"
  source_file = "./lambda-proxy/index.py"
  output_path = "./lambda-proxy/lambda.zip"
}

resource "aws_iam_role" "lambda_proxy" {
  name = "${local.project}-lambda-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = ["sts:AssumeRole"]
    }]
  })
}

resource "aws_iam_policy" "lambda_proxy" {
  name = "${local.project}-lambda-proxya-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeInstances",
          "ec2:AttachNetworkInterface"
        ],
        Effect = "Allow",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_proxy" {
  role       = aws_iam_role.lambda_proxy.id
  policy_arn = aws_iam_policy.lambda_proxy.arn
}

module "security_group_dataexfiltration_lambda_proxy" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${local.project}-securitygroup-lambda-proxy"
  description = "Allow ingress/egress"
  vpc_id      = module.vpc_dataexfiltration.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "allow-ingress-http"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "allow-ingress-https"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = -1
      to_port     = -1
      protocol    = -1
      description = "allow-egress-all"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

resource "aws_lambda_function" "lambda_proxy" {
  function_name    = "${local.project}-lambda-proxy"
  filename         = data.archive_file.lambda_proxy.output_path
  role             = aws_iam_role.lambda_proxy.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.12"
  layers           = [aws_lambda_layer_version.tls_inspection.arn]
  source_code_hash = data.archive_file.lambda_proxy.output_base64sha512
  vpc_config {
    subnet_ids         = module.vpc_dataexfiltration.private_subnets
    security_group_ids = [module.security_group_dataexfiltration_lambda_proxy.security_group_id]
  }
  environment {
    variables = {
      REQUESTS_CA_BUNDLE = "/opt/cert.pem"
    }
  }
}

resource "aws_lambda_function_url" "lambda_proxy" {
  function_name      = aws_lambda_function.lambda_proxy.function_name
  authorization_type = "NONE"
}

output "aws_lambda_proxy_function_url" {
  value = aws_lambda_function_url.lambda_proxy.function_url
}
