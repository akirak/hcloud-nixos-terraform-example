# An Example of Deploying NixOS to Hetzner Cloud using Terraform from GitHub Action

This repository contains a set of GitHub workflows used to provision and destroy
a NixOS VPS instance on [Hetzner Cloud](https://www.hetzner.com/cloud/). It uses
a kexec image available from
[nix-community/nixos-images](https://github.com/nix-community/nixos-images) to
bootstrap an installation environment. The approach is based on
[nixos-anywhere](https://github.com/nix-community/nixos-anywhere), but the
installation process is customized to serve specific needs.

The root file system is encrypted on LUKS. After the instance creation, you have
to log in to the instance to unlock the file system. Also it uses Terraform
Cloud, which is not so popular nowadays, as the state backend of Terraform.
The project is no longer maintained, so tweak it as needed.

## Inspiration

Originally inspired by
[nixos-anywhere](https://github.com/nix-community/nixos-anywhere) (formerly
nixos-remote).
