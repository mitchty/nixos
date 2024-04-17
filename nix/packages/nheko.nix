{ stdenv
, lib
, pkgs
}:
with pkgs; stdenv.mkDerivation rec {
  name = "nheko";
  uname = "Nheko-Reborn";
  aname = "Nheko";
  version = "0.11.3";

  buildInputs = [ undmg ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    install -dm755 "$out/Applications"
    cp -r ${aname}.app "$out/Applications/${aname}.app"
  '';

  src = fetchurl {
    name = "${aname}.dmg";
    url = "https://github.com/${uname}/${name}/releases/download/v${version}/${name}-v${version}-intel.dmg";
    sha256 = "sha256-NXbmqU5sqtVKrdu3FDbeityRnezLVxryvtPIcbYwpDA=";
  };

  latest = "curl --silent 'https://api.github.com/repos/${uname}/${name}/releases/latest' | jq -r '.tag_name' | tr -d v";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
