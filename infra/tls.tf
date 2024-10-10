# private key
resource "tls_private_key" "tls_inspection" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# certificate
resource "tls_self_signed_cert" "tls_inspection" {
  private_key_pem = tls_private_key.tls_inspection.private_key_pem

  subject {
    common_name = "pagopa"
    organization = "PagoPA S.p.A"
    country = "Italy"
    province = "Rome"
  }

  validity_period_hours = 24*365*10

  is_ca_certificate = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}
