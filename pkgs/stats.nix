{ stdenv
, lib
, pkgs
}:

with pkgs; stdenv.mkDerivation rec {
  name = "stats";
  uname = "exelban";
  aname = "Stats";
  version = "2.8.6";

  buildInputs = [ undmg ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    install -dm755 "$out/Applications"
    cp -r ${aname}.app "$out/Applications/${aname}.app"
  '';

  src = fetchurl {
    url = "https://github.com/${uname}/${name}/releases/download/v${version}/${aname}.dmg";
    sha256 = "sha256-1vWSwXxjL1wh++fdpRCK0sBES/UvvKRD6ZL1eY81dbw=";
  };

  latest = "curl --silent 'https://api.github.com/repos/exelban/stats/releases/latest' | jq -r '.tag_name' | tr -d v";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
