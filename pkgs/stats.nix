{ stdenv
, lib
, pkgs
}:

with pkgs; stdenv.mkDerivation rec {
  name = "stats";
  uname = "exelban";
  aname = "Stats";
  version = "2.9.6";

  buildInputs = [ undmg ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    install -dm755 "$out/Applications"
    VOLUME=$(/usr/bin/hdiutil attach -nobrowse $src | awk '/Volumes/ {print $3}')
    trap "/usr/bin/hdiutil detach $VOLUME" EXIT
    APP="$(echo $VOLUME/*.app)"
    cp -rf "$APP" "$out/Applications/$(basename "$APP")"
  '';

  src = fetchurl {
    url = "https://github.com/${uname}/${name}/releases/download/v${version}/${aname}.dmg";
    sha256 = "sha256-rbv8YlBfq0cEqv8Hwoi5Qmai2ROl3IHdmSd9SCCZtSM=";
  };

  latest = "curl --silent 'https://api.github.com/repos/exelban/stats/releases/latest' | jq -r '.tag_name' | tr -d v";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
