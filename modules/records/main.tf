data "aws_route53_zone" "server-records" {
  name         = var.domain-name
  private_zone = false
}

resource "aws_route53_record" "nexus-record" {
  zone_id = data.aws_route53_zone.server-records.zone_id
  name    = var.nexus-domain-name
  type    = "A"

  alias {
    name                   = var.nexus-dns-name
    zone_id                = var.nexus-zone-id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "sonarqube-record" {
  zone_id = data.aws_route53_zone.server-records.zone_id
  name    = var.sonarqube-domain-name
  type    = "A"

  alias {
    name                   = var.sonarqube-dns-name
    zone_id                = var.sonarqube-zone-id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "stage-record" {
  zone_id = data.aws_route53_zone.server-records.zone_id
  name    = var.stage-domain-name
  type    = "A"

  alias {
    name                   = var.stage-dns-name
    zone_id                = var.stage-zone-id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "prod-record" {
  zone_id = data.aws_route53_zone.server-records.zone_id
  name    = var.prod-domain-name
  type    = "A"

  alias {
    name                   = var.prod-dns-name
    zone_id                = var.prod-zone-id
    evaluate_target_health = true
  }
}