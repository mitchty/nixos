{ stdenv
, lib
, pkgs
}:
with pkgs; stdenv.mkDerivation rec {
  name = "franz";
  uname = "meetfranz";
  aname = "Franz";
  version = "5.10.0";

  buildInputs = [ undmg ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    install -dm755 "$out/Applications"
    cp -r ${aname}.app "$out/Applications/${aname}.app"
  '';

  src = fetchurl {
    name = "${aname}.dmg";
    url = "https://github.com/${uname}/${name}/releases/download/v${version}/${aname}-${version}.dmg";
    sha256 = "sha256-3Hvvltq9C4YZlDDNdpmxfa5svG6uX2lisU2TOB0N+FM=";
  };

  latest = "curl --silent 'https://api.github.com/repos/${uname}/${name}/releases/latest' | jq -r '.tag_name' | tr -d v";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
