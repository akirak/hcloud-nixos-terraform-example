#!/usr/bin/env bash

set -euox pipefail

disko_command="nix run github:nix-community/disko \
    --extra-experimental-features nix-command \
    --extra-experimental-features flakes \
    --no-write-lock-file --"

dd if=/dev/urandom of=${luks_key} bs=512 count=4

# disko fails to mount partition if create and mount are done in a single
# execution. It may be safer to create and mount in separate steps and running
# sync between them.
$${disko_command} --mode create --flake "${disko_config}"
sync
$${disko_command} --mode mount --flake "${disko_config}"

mkdir -p /mnt/persist
echo "${nixos_config}" > /mnt/persist/config-flake

ssh-keygen -t ed25519 -N "" -f "${boot_ed25519_key}"
boot_key="/mnt${boot_ed25519_key}"
mkdir -p $(dirname $boot_key)
cp "${boot_ed25519_key}" "$boot_key"

# The encryption key is copied to an encrypted partition in the installation,
# but not to the initrd. You can back it up to your local machine later.
luks_key="/mnt${luks_key}"
mkdir -p $(dirname $luks_key)
cp "${luks_key}" "$luks_key"

cat "${luks_pass_file}" | cryptsetup --key-file="${luks_key}" luksChangeKey ${luks_device}

mkdir -p /mnt/etc
cp "${cachix_agent_token_temp_file}" /mnt/etc/cachix-agent.token

nixos-install \
    --no-write-lock-file \
    --no-root-password \
    --no-channel-copy \
    --show-trace \
    --flake "${nixos_config}"

# Use `shutdown -r now` to only shutdown
systemd-run --on-active=1 reboot
