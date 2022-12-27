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
      "command -v nix || curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NIX_CHANNEL=nixos-22.11 NO_REBOOT=1 bash 2>&1 | tee /tmp/infect.log",
      "shutdown -r 1"
    ]
  }
}
