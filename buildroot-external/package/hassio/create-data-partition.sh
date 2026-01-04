#!/usr/bin/env bash
set -e

build_dir=$1
dst_dir=$2
channel=$3
docker_version=$4

data_img="${dst_dir}/data.ext4"
data_dir="${build_dir}/data"

# Default to stable channel if empty
if [ -z "$channel" ]; then
    channel="stable"
fi

APPARMOR_URL="https://version.home-assistant.io/apparmor_${channel}.txt"

# Cleanup function
cleanup() {
    echo "Cleaning up..."
    if mountpoint -q "${data_dir}" 2>/dev/null; then
        echo "Unmounting ${data_dir}..."
        sudo umount -f "${data_dir}" 2>/dev/null || sudo umount -l "${data_dir}" 2>/dev/null || true
    fi
}

trap cleanup EXIT

# Make image
rm -f "${data_img}"
truncate --size="1280M" "${data_img}"
mkfs.ext4 -L "hassos-data" -E lazy_itable_init=0,lazy_journal_init=0 "${data_img}"

# Mount / init file structs
mkdir -p "${data_dir}"
sudo mount -o loop,discard "${data_img}" "${data_dir}"

# Skip Docker-in-Docker approach and manually create data partition structure
# Container images will be pulled from ghcr.io at runtime instead of being bundled
sudo bash -ex <<EOF
# Indicator for docker-prepare.service to use the containerd snapshotter
touch "${data_dir}/.docker-use-containerd-snapshotter"

# Create necessary directory structure
mkdir -p "${data_dir}/docker"
mkdir -p "${data_dir}/supervisor/apparmor"

# Setup AppArmor
curl -fsL -o "${data_dir}/supervisor/apparmor/hassio-supervisor" "${APPARMOR_URL}"

# Persist build-time updater channel
jq -n --arg channel "${channel}" '{"channel": \$channel}' > "${data_dir}/supervisor/updater.json"

# Create initial docker directory structure for containerd snapshotter
mkdir -p "${data_dir}/docker/containerd"
mkdir -p "${data_dir}/docker/containerd/snapshots"
mkdir -p "${data_dir}/docker/containerd/metadata"
EOF
