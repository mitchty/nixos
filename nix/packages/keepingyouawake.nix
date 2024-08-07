{
  stdenv,
  lib,
  pkgs,
}:
with pkgs;
stdenv.mkDerivation rec {
  name = "newmarcel";
  uname = "KeepingYouAwake";
  aname = "KeepingYouAwake";
  version = "1.6.5";

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
    url = "https://github.com/${name}/${uname}/releases/download/${version}/${uname}-${version}.zip";
    sha256 = "sha256-Tp2HnJXL+OJTcJdMK4h18Xsqo7nClbt20Np0zYM6/gQ=";
  };

  latest = "curl --silent 'https://api.github.com/repos/${name}/${uname}/releases/latest' | jq -r '.tag_name'";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
