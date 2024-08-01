{
  stdenv,
  lib,
  pkgs,
}:
with pkgs;
stdenv.mkDerivation rec {
  name = "dwarvesf";
  uname = "hidden";
  aname = "Hidden.Bar";
  version = "1.9";

  sourceRoot = ".";
  phases = [ "installPhase" ];
  installPhase = ''
    set -x
    install -dm755 "$out/Applications"
    VOLUME=$(/usr/bin/hdiutil attach -nobrowse $src | awk '/Volumes/ { print substr($0, index($0,$3)) }')
    trap "/usr/bin/hdiutil detach \"$VOLUME\"" EXIT INT HUP TERM
    APP=$(${pkgs.findutils}/bin/find "$VOLUME" -maxdepth 1 -name '*.app')
    cp -rf "$APP" "$out/Applications/$(basename \"$APP\").app"
  '';

  src = fetchurl {
    name = "${aname}.dmg";
    url = "https://github.com/${name}/${uname}/releases/download/v${version}/${aname}.${version}.dmg";
    sha256 = "sha256-P1SwJPXBxAvBiuvjkBRxAom0fhR+cVYfriKmYcqybQI=";
  };

  latest = "curl --silent 'https://api.github.com/repos/${name}/${uname}/releases/latest' | jq -r '.tag_name' | tr -d v";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
