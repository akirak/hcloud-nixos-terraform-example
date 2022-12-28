{ pkgs, ... }:

{
  # Terraform
  languages.terraform.enable = true;
  pre-commit.hooks.terraform-format.enable = true;
}
