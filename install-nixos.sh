#!/usr/bin/env bash

set -euox pipefail

disko_command="nix run github:nix-community/disko \
    --extra-experimental-features nix-command \
    --extra-experimental-features flakes \
    --no-write-lock-file --"

# disko fails to mount partition if create and mount are done in a single
# execution. It may be safer to create and mount in separate steps and running
# sync between them.
$${disko_command} --mode create --flake "${disko_config}"
sync
$${disko_command} --mode mount --flake "${disko_config}"

nixos-install \
    --no-write-lock-file \
    --no-root-password \
    --no-channel-copy \
    --show-trace \
    --flake "${nixos_config}"

mkdir /persist
echo "${nixos_config}" > /persist/config-flake

# Use `shutdown -r now` to only shutdown
systemd-run --on-active=1 reboot
