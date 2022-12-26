terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.36.2"
    }
  }

  cloud {
    organization = "akirak"
    workspaces {
      name = "github-actions-hetzner-cloud-example"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}
