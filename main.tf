locals {
  nixos_config = "github:akirak/homelab/shu#shu"
  disko_config = "github:akirak/homelab/shu#shu"
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

resource "local_file" "nixos_installer" {
  filename = "install-nixos.sh"
  content = templatefile("${path.module}/install-nixos.sh", {
    "nixos_config" : local.nixos_config
    "disko_config" : local.disko_config
  })
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

  connection {
    type        = "ssh"
    user        = "root"
    host        = self.ipv4_address
    private_key = local_sensitive_file.private_key.content
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "DEBIAN_FRONTEND=noninteractive apt-get install kexec-tools",
      "curl -L https://github.com/nix-community/nixos-images/releases/download/nixos-unstable/nixos-kexec-installer-x86_64-linux.tar.gz | tar -xzf- -C /root",
      "/root/kexec/run",
      # Keep the session open before the machine starts booting into NixOS
      "sleep 6"
    ]
  }

  provisioner "remote-exec" {
    script = local_file.nixos_installer.filename
  }

  # Wait for NixOS to reboot
  provisioner "local-exec" {
    command = "sleep 10"
  }
}
