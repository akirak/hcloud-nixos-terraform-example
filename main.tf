locals {
  nixos_config                 = "github:akirak/homelab#shu"
  disko_config                 = "github:akirak/homelab#shu"
  boot_ed25519_key             = "/persist/boot_ed25519_key"
  luks_key                     = "/persist/luks-cryptroot.key"
  luks_device                  = "/dev/sda3"
  luks_pass_file               = "/tmp/luks-passphrase"
  cachix_agent_token_temp_file = "/tmp/cachix-agent.token"
}

resource "hcloud_ssh_key" "ephemeral_ssh_key" {
  name       = "id_hcloud_ephemeral.pub"
  public_key = file(var.public_key_file)
}

resource "local_file" "nixos_installer" {
  filename = "install-nixos.sh"
  content = templatefile("${path.module}/install-nixos.sh", {
    "nixos_config" : local.nixos_config
    "disko_config" : local.disko_config
    "boot_ed25519_key" : local.boot_ed25519_key
    "luks_key" : local.luks_key
    "luks_pass_file" : local.luks_pass_file
    "luks_device" : local.luks_device
    "cachix_agent_token_temp_file" : local.cachix_agent_token_temp_file
  })
}

resource "hcloud_server" "shu" {
  name        = "shu"
  image       = "114690387"
  server_type = "cpx21"
  location    = "hil"
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  ssh_keys = [
    "${hcloud_ssh_key.ephemeral_ssh_key.id}",
  ]

  connection {
    type        = "ssh"
    user        = "root"
    host        = self.ipv4_address
    private_key = file(var.private_key_file)
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "DEBIAN_FRONTEND=noninteractive apt-get -y install kexec-tools",
      "curl -L https://github.com/nix-community/nixos-images/releases/download/nixos-unstable/nixos-kexec-installer-x86_64-linux.tar.gz | tar -xzf- -C /root",
      "/root/kexec/run",
      # Keep the session open before the machine starts booting into NixOS
      "sleep 6"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /persist"
    ]
  }

  provisioner "file" {
    source      = var.luks_passphrase_file
    destination = local.luks_pass_file
  }

  provisioner "file" {
    content     = <<-TOKEN
      CACHIX_AGENT_TOKEN=${var.cachix_agent_token}
    TOKEN
    destination = local.cachix_agent_token_temp_file
  }

  provisioner "remote-exec" {
    script = local_file.nixos_installer.filename
  }

  # Wait for NixOS to reboot
  provisioner "local-exec" {
    command = "sleep 10"
  }
}
