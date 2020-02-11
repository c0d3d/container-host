variable "gcp_key_file" {
  type = string
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
  nixos_config = "./load-balancer.nix"
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
