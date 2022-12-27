resource "hcloud_ssh_key" "default" {
  name       = "default"
  public_key = var.public_key
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
    "${hcloud_ssh_key.default.name}"
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
      "echo Hello"
    ]
  }
}
