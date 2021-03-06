#!/usr/bin/env nix-shell
#-*-mode: Shell-script; coding: utf-8;-*-
#!nix-shell -i bash -p bash jq coreutils curl
# File: versions.sh
# Copyright: 2022 Mitchell Tishmack
# Description: Script for ci to run to see if any specific package(s) have newer versions
_base=$(basename "$0")
_dir=$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P || exit 126)
export _base _dir

set -e

# TODO: for now just look for certain things, future me figure out how to nix
# eval what packages are present in the flake.

ok=0

# 2> /dev/null to nuke the stderr warning: messages
for pkg in seaweedfs hwatch bottom jira-cli; do
  latest=$(eval $(nix eval --raw ".#${pkg}.latest" 2> /dev/null ))
  ours=$(nix eval --raw ".#${pkg}.version" 2> /dev/null)
  if [ "${latest}" != "${ours}" ]; then
    printf "%s latest version out of date: latest=%s ours=%s\n" "${pkg}" "${latest}" "${ours}"
    ok=$((ok+1))
  fi
done

exit $ok
