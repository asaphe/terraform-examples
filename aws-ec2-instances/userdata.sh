#!/usr/bin/env bash

set -e

function mount_volume {
  local -r device_name="${1:-/dev/xvdb}"
  local -r file_system_type="${2:-xfs}"
  local -r fs_tab_path="/etc/fstab"

  case "${file_system_type}" in
    "ext4")
      echo -e "Creating ${file_system_type} file system on ${device_name}"
      mkfs.ext4 -F "${device_name}"
      ;;
    "xfs")
      echo -e "Creating ${file_system_type} file system on ${device_name}"
      mkfs.xfs -f "${device_name}"
      ;;
    *)
      exit 1
  esac