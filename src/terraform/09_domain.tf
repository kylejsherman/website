locals {
  domain_tags = {
    purpose = "domain"
  }
}

###########################################################################
# Import the hosted zone
###########################################################################
resource "aws_route53_zone" "kylejsherman" {
  name = "kylejsherman.com"
  tags = merge(
    local.domain_tags,
    {
    Name = "website_domain"
    }
  )
}

resource "aws_route53_record" "MX" {
  zone_id = aws_route53_zone.kylejsherman.zone_id
  name = "kylejsherman.com"
  type = "MX"
  ttl = 300
  records = [
    "10 mail.protonmail.ch",
    "20 mailsec.protonmail.ch"
  ]
}

resource "aws_route53_record" "TXT" {
  zone_id = aws_route53_zone.kylejsherman.zone_id
  name = "kylejsherman.com"
  type = "TXT"
  ttl = 300
  records = [
    "protonmail-verification=5e8896d150e3a1b2aede4c42954688fd11ee7bc6",
    "v=spf1 include:_spf.protonmail.ch mx ~all"
  ]
}

resource "aws_route53_record" "dmarcTXT" {
  zone_id = aws_route53_zone.kylejsherman.zone_id
  name = "_dmarc.kylejsherman.com"
  type = "TXT"
  ttl = 300
  records = [
    "v=DMARC1; p=none"
  ]
}

resource "aws_route53_record" "CNAME1" {
  zone_id = aws_route53_zone.kylejsherman.zone_id
  name = "protonmail._domainkey.kylejsherman.com"
  type = "CNAME"
  ttl = 300
  records = [
    "protonmail.domainkey.didpeswzfpt6yc5nqxmcukufhs3uoprqhljh2s66citli56hqzvya.domains.proton.ch."
  ]
}

resource "aws_route53_record" "CNAME2" {
  zone_id = aws_route53_zone.kylejsherman.zone_id
  name = "protonmail2._domainkey.kylejsherman.com"
  type = "CNAME"
  ttl = 300
  records = [
    "protonmail2.domainkey.didpeswzfpt6yc5nqxmcukufhs3uoprqhljh2s66citli56hqzvya.domains.proton.ch."
  ]
}

resource "aws_route53_record" "CNAME3" {
  zone_id = aws_route53_zone.kylejsherman.zone_id
  name = "protonmail3._domainkey.kylejsherman.com"
  type = "CNAME"
  ttl = 300
  records = [
    "protonmail3.domainkey.didpeswzfpt6yc5nqxmcukufhs3uoprqhljh2s66citli56hqzvya.domains.proton.ch."
  ]
}

# resource "aws_acm_certificate" "cert" {
#   domain_name = "kylejsherman.com"
#   subject_alternative_names = ["*.kylejsherman.com"]
#   validation_method = "DNS"
#   lifecycle {
#     create_before_destroy = true
#   }
#   tags = merge(
#     local.domain_tags,
#     {
#     Name = "email"
#     }
#   )
# }

# resource "aws_route53_record" "acmValidation" {
#   zone_id = aws_route53_zone.kylejsherman.zone_id
#   name = aws_acm_certificate.cert.domain_validation_options.0.resource_record_name
#   type = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
#   ttl = 300
#   records = [
#     ws_acm_certificate.cert.domain_validation_options.0.resource_record_value
#   ]
# }

# resource "aws_acm_certificat_validation" "validateCert" {
#   certificate_arn = aws_acm_certificat.cert.arn
#   validation_record_fqdns = [
#     aws_route53_record.acmValidation.fqdn
#   ]
# }