#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash coreutils puppeteer-cli python310Packages.pdfx
#-*-mode: Shell-script; coding: utf-8;-*-
# SPDX-License-Identifier: BlueOak-1.0.0
# Description: Check for updates to firmware for crap I own, none of this shell
# is pretty, just functional enough to get the job done.
_base=$(basename "$0")
_dir=$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P || exit 126)
export _base _dir

set -eu

#shellcheck source=../../nix/static/src/lib.sh
. ~/src/pub/github.com/mitchty/nix/static/src/lib.sh

version="${1?}"

# 2> /dev/null to nuke the stderr warning: messages
pkg=hwatch
version=$(nix eval --raw ".#${pkg}.version" 2> /dev/null)

gi blacknon/hwatch
git fetch
git unstage Cargo.lock
git reset --hard HEAD
git checkout tags/${version}
cargo update
git add -f Cargo.lock
git diff --cached > ~/src/pub/github.com/mitchty/nixos/patches/hwatch-add-cargo-lock.patch
