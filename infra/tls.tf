# private key
resource "tls_private_key" "tls_inspection" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# certificate
resource "tls_self_signed_cert" "tls_inspection" {
  private_key_pem = tls_private_key.tls_inspection.private_key_pem

  subject {
    common_name  = "pagopa"
    organization = "PagoPA S.p.A"
    country      = "Italy"
    province     = "Rome"
  }

  validity_period_hours = 24 * 365 * 10

  is_ca_certificate = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "tls_inspection" {
  certificate_body  = tls_self_signed_cert.tls_inspection.cert_pem
  private_key       = tls_self_signed_cert.tls_inspection.private_key_pem
  certificate_chain = tls_self_signed_cert.tls_inspection.cert_pem
}

resource "aws_networkfirewall_tls_inspection_configuration" "tls_inspection" {
  name        = "${local.project}-tls-inspection"
  description = "tls-inspection"

  tls_inspection_configuration {
    server_certificate_configuration {
      certificate_authority_arn = aws_acm_certificate.tls_inspection.arn
      # TODO: not works manually update this on AWS console
      check_certificate_revocation_status {
        revoked_status_action = "DROP"
        unknown_status_action = "DROP"
      }
      scope {
        protocols = [6]
        destination_ports {
          from_port = 0
          to_port   = 65535
        }
        destination {
          address_definition = "0.0.0.0/0"
        }
        source_ports {
          from_port = 0
          to_port   = 65535
        }
        source {
          address_definition = "0.0.0.0/0"
        }
      }
    }
  }
}