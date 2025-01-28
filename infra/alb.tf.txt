resource "aws_security_group" "load_balancer" {
  name        = "${local.project}-lb-sg"
  description = "Allow HTTP/s traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "main" {
  name               = "${local.project}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = aws_subnet.load_balancer[*].id

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "lambda_proxy" {
  name        = "${local.project}-lambda-proxy-tg"
  target_type = "lambda"
  vpc_id      = aws_vpc.main.id
}

# Listener ALB
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lambda_proxy.arn
  }
}

resource "aws_lb_target_group_attachment" "lambda_proxy_attachment" {
  depends_on       = [aws_lambda_permission.lambda_proxy_lb_main]
  target_group_arn = aws_lb_target_group.lambda_proxy.arn
  target_id        = aws_lambda_function.lambda_proxy.arn
}

resource "aws_lambda_permission" "lambda_proxy_lb_main" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_proxy.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.lambda_proxy.arn
}

output "lb_dns_name" {
  value = aws_lb.main.dns_name
}
