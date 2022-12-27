resource "hcloud_ssh_key" "default" {
  name       = "default"
  public_key = var.public_key
}

resource "hcloud_ssh_key" "yubikey" {
  name       = "yubikey"
  public_key = var.public_key_2
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
    "${hcloud_ssh_key.yubikey.name}"
  ]
  # user_data = file("hcloud/user_data.yaml")

  connection {
    type = "ssh"
    user = "root"
    host = self.ipv4_address
    private_key = file("terraform-cloud.pem")
  }

  provisioner "remote-exec" {
    inline = [
      # I need to watch the progress of nixos-infect, so I would prefer running it inside remote-exec rather than cloud-init
      "curl https://raw.githubusercontent.com/akirak/nixos-infect/flakes/nixos-infect | NIX_CHANNEL=nixos-22.11 FLAKE_URL=github:akirak/homelab/basic-hcloud NIXOS_CONFIG_NAME=hcloud-basic NO_REBOOT=1 bash 2>&1 | tee /var/log/infect.log",
      "shutdown -r 3"
    ]
  }
}
