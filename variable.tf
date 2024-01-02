variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "public_key_file" {
  type = string
}

variable "private_key_file" {
  type      = string
}

variable "luks_passphrase" {
  type      = string
  sensitive = true
}

variable "cachix_agent_token" {
  type      = string
  sensitive = true
}
