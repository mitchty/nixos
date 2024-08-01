{
  stdenv,
  lib,
  pkgs,
}:
with pkgs;
stdenv.mkDerivation rec {
  name = "freetube";
  uname = "FreeTubeApp";
  aname = "FreeTube";
  version = "0.20.0";

  buildInputs = [ undmg ];
  sourceRoot = ".";
  phases = [
    "unpackPhase"
    "installPhase"
  ];
  installPhase = ''
    install -dm755 "$out/Applications"
    cp -r ${aname}.app "$out/Applications/${aname}.app"
  '';

  src = fetchurl {
    name = "${aname}.dmg";
    url = "https://github.com/${uname}/${aname}/releases/download/v${version}-beta/${name}-${version}-mac-x64.dmg";
    sha256 = "sha256-vJTFsGu/JIDi/unl3b9CdJA+r1ENTYzoe6hN4O0EDlk=";
  };

  # For some weird reason *EVERY* release they have is a pre-release tagged with
  # -beta, so whatever just find the latest pre-release
  latest = "curl --silent 'https://api.github.com/repos/${uname}/${aname}/releases' | jq -r 'map(select(.prerelease)) | first | .tag_name' | tr -d v | sed -e 's/-beta//g'";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
