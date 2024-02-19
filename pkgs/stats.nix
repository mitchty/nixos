{ stdenv
, lib
, pkgs
}:

with pkgs; stdenv.mkDerivation rec {
  name = "stats";
  uname = "exelban";
  aname = "Stats";
  version = "2.10.1";

  buildInputs = [ undmg ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    set -x
    install -dm755 "$out/Applications"
    VOLUME=$(/usr/bin/hdiutil attach -nobrowse $src | awk '/Volumes/ { print substr($0, index($0,$3)) }')
    trap "/usr/bin/hdiutil detach \"$VOLUME\"" EXIT INT HUP TERM
    APP=$(${pkgs.findutils}/bin/find "$VOLUME" -maxdepth 1 -name '*.app')
    cp -rf "$APP" $out/Applications/$(basename "$APP")
  '';

  src = fetchurl {
    url = "https://github.com/${uname}/${name}/releases/download/v${version}/${aname}.dmg";
    sha256 = "sha256-t+25ka3N1TmD6C2LhTXyNX7KuzhEPHpsmhj51Wmd1ZE=";
  };

  latest = "curl --silent 'https://api.github.com/repos/exelban/stats/releases/latest' | jq -r '.tag_name' | tr -d v";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
