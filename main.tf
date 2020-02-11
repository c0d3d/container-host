variable "gcp_key_file" {
  type = string
}

variable "domain" {
  type = string
  default = "kylesferrazza.com"
}

provider "google" {
  credentials = file(var.gcp_key_file)
  project = "container-host"
  region  = "us-east1"
  zone    = "us-east1-b"
}

resource "google_compute_address" "container-host-ip" {
  name = "container-host-ip"
}

resource "google_compute_firewall" "default" {
  name = "web-firewall"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["web"]
}

resource "google_storage_bucket" "image-store" {
  name = "container-host-image-store"
}

module "nix_image" {
  source = "github.com/tweag/terraform-nixos//google_image_nixos_custom?ref=1c614a64597021bc07a738f9e461ce0ae254fb2a"
  nixos_config = "./image.nix"
  bucket_name = google_storage_bucket.image-store.name
}

resource "google_compute_instance" "container-host-vm" {
  name = "container-host"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = module.nix_image.self_link
    }
  }

  tags = ["web"]

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.container-host-ip.address
      #public_ptr_domain_name = "nix.${var.domain}"
    }
  }
}

variable "cloudflare_zone_id" {
  type = string
}

variable "email" {
  type = string
  default = "kyle.sferrazza@gmail.com"
}

variable "cloudflare_api_key" {
  type = string
}

provider "cloudflare" {
  email = var.email
  api_key = var.cloudflare_api_key
}

resource "cloudflare_record" "container-host-record" {
  zone_id = var.cloudflare_zone_id
  name = "nix"
  value = google_compute_address.container-host-ip.address
  type = "A"
  ttl = 300
}

resource "cloudflare_record" "container-host-wildcard-record" {
  zone_id = var.cloudflare_zone_id
  name = "*.nix"
  value = google_compute_address.container-host-ip.address
  type = "A"
  ttl = 300
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "reg_private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.reg_private_key.private_key_pem
  email_address = var.email
}

resource "acme_certificate" "ssl_cert" {
  account_key_pem = acme_registration.reg.account_key_pem
  common_name = "nix.${var.domain}"
  subject_alternative_names = ["*.nix.${var.domain}"]

  dns_challenge {
    provider = "cloudflare"
    config = {
      CF_API_EMAIL = var.email
      CF_API_KEY = var.cloudflare_api_key
    }
  }
}

output "privkey" {
  value = acme_certificate.ssl_cert.private_key_pem
  sensitive = true
}

output "cert" {
  value = "${acme_certificate.ssl_cert.certificate_pem}"
  sensitive = true
}

output "fullchain" {
  value = "${acme_certificate.ssl_cert.certificate_pem}\n${acme_certificate.ssl_cert.issuer_pem}"
  sensitive = true
}
