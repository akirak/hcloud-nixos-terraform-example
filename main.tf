locals {
  nixos_flake  = "github:akirak/homelab/basic-hcloud"
  nixos_config = "hcloud-basic"
}

resource "hcloud_ssh_key" "default" {
  name       = "default"
  public_key = var.public_key
}

resource "local_sensitive_file" "private_key" {
  filename        = "${path.module}/terraform-cloud.pem"
  content         = var.private_key
  file_permission = "0600"
}

resource "hcloud_server" "default" {
  name        = "default"
  image       = "debian-11"
  server_type = "cpx21"
  location    = "hil"
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  ssh_keys = [
    "${hcloud_ssh_key.default.name}",
  ]
  # user_data = file("hcloud/user_data.yaml")

  connection {
    type        = "ssh"
    user        = "root"
    host        = self.ipv4_address
    private_key = local_sensitive_file.private_key.content
  }

  provisioner "remote-exec" {
    inline = [
      "apt update",
      "apt install kexec-tools --yes --force"
    ]
  }
}
