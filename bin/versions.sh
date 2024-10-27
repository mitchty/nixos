#!/usr/bin/env nix-shell
#-*-mode: Shell-script; coding: utf-8;-*-
#!nix-shell -i bash -p bash jq coreutils curl htmlq
# File: versions.sh
# Copyright: 2022 Mitchell Tishmack
# Description: Script for ci to run to see if any specific package(s) have newer versions
_base=$(basename "$0")
_dir=$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P || exit 126)
export _base _dir

${SETOPTS:+set ${SETOPTS}}

# TODO: for now just look for certain things, future me figure out how to nix
# eval what packages are present in the flake.

ok=0

${DIR:+cd $DIR}

junk="ytdl-sub jira-cli"

if [ "$(uname -s)" = "Darwin" ]; then
  # For now ignore the macos stuff when ran on linux
  junk="${junk} freetube keepingyouawake ferdium clocker maccy nheko obs-studio stats stretchly swiftbar wireshark vlc"
fi

# 2> /dev/null to nuke the stderr warning: messages
for pkg in ${junk}; do
  evalstring=$(nix eval --raw ".#${pkg}.latest" 2> /dev/null)
  if [ "$?" -eq 0 ]; then
    latest=$(eval "${evalstring}")
    ours=$(nix eval --raw ".#${pkg}.version" 2> /dev/null)

    if [ "$?" -eq 0 ]; then
      if [ "${latest}" != "${ours}" ]; then
        printf "%s latest version out of date: ours=%s latest=%s\n" "${pkg}" "${ours}" "${latest}" >&2
        printf "nix run github:MiC92/nix-update -- --flake %s --version %s\n" "${pkg}" "${latest}"
        ok=$((ok + 1))
      fi
    fi
  fi
done

exit $ok
