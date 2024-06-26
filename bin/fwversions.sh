#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash coreutils puppeteer-cli python310Packages.pdfx
#-*-mode: Shell-script; coding: utf-8;-*-
# SPDX-License-Identifier: BlueOak-1.0.0
# Description: Check for updates to firmware for crap I own, none of this shell
# is pretty, just functional enough to get the job done.
_base=$(basename "$0")
_dir=$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P || exit 126)
export _base _dir

set "${SETOPTS:--eu}"

ok=1

TEMP=${TMPDIR:-/tmp}
T="${TEMP}/${_base}-$$"

install -dm755 "${T}"

cleanup() {
  [ -d "${T}" ] && rm -fr "${T}"
  [ ${ok} -ne 0 ] && printf "note: %s did not succesfully try again with SETOPTS=-eux\n" "${_base}" >&2
  exit $ok
}

trap cleanup EXIT

cd "${T}"

puppeteer print --no-sandbox https://tascam.com/us/product/mixcast_4/download test.pdf > /dev/null 2>&1

curr="https://tascam.com/downloads/products/tascam/mixcast_4/mixcast4_fw_v131.zip"
latest=$(pdfx -v test.pdf | grep -E '(mixcast_4.*_fw_.*.zip)' | sort -ur | head -n1 | awk '{print $2}')

if [[ "${curr}" != "${latest}" ]]; then
  ok=$((ok + 1))
  old=$(echo ${curr} | awk -F\_v '{print $2}' | tr -d '.zip')
  new=$(echo ${latest} | awk -F\_v '{print $2}' | tr -d '.zip')
  printf "mixcast 4 firmware skew current=%s found=%s\n" "${old}" "${new}"
  printf "change curr to: %s\n" "${latest}"
else
  ok=0
fi
