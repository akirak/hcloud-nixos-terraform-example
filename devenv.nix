{ pkgs, ... }:

{
  # Terraform
  languages.terraform.enable = true;
  pre-commit.hooks.terraform-format.enable = true;

  scripts.format.exec = ''
    terraform fmt
  '';

  scripts.lint.exec = ''
    terraform fmt -check -write=false
  '';

  scripts.validate.exec = ''
    terraform validate
    tfsec
  '';
}
