{
  stdenv,
  lib,
  pkgs,
}:
with pkgs;
stdenv.mkDerivation rec {
  name = "noTunes";
  uname = "tombonez";
  aname = "noTunes";
  version = "3.3";

  buildInputs = [ unzip ];
  sourceRoot = ".";
  phases = [
    "unpackPhase"
    "installPhase"
  ];
  installPhase = ''
    install -dm755 "$out/Applications"
    APP="$(echo *.app)"
    cp -rf "$APP" "$out/Applications/$(basename "$APP")"
  '';

  src = fetchurl {
    name = "${aname}.zip";
    url = "https://github.com/${uname}/${name}/releases/download/v${version}/${aname}-${version}.zip";
    sha256 = "sha256-LnqiNikn6oRdFTHfyTWkYm+2ufsYc8kLvDl/YXF1fyA=";
  };

  latest = "curl --silent 'https://api.github.com/repos/${name}/${aname}/releases/latest' | jq -r '.tag_name' | tr -d v";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
