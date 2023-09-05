{ stdenv
, lib
, pkgs
}:
with pkgs; stdenv.mkDerivation rec {
  name = "ferdium";
  uname = "ferdium";
  aname = "Ferdium";
  version = "6.4.1";

  buildInputs = [ undmg ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    install -dm755 "$out/Applications"
    cp -r ${aname}.app "$out/Applications/${aname}.app"
  '';

  src = fetchurl {
    name = "${aname}.dmg";
    url = "https://github.com/${uname}/${name}-app/releases/download/v${version}/${aname}-mac-${version}-x64.dmg";
    sha256 = "sha256-sSEYaYN/4BPSehJ8fY+f3xFmDjZxIdHdEcoKgMEEnnY=";
  };

  latest = "curl --silent 'https://api.github.com/repos/${uname}/${name}-app/releases/latest' | jq -r '.tag_name' | tr -d v";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
# https://github.com/ferdium/ferdium-app/releases/download/v6.4.1/Ferdium-mac-6.4.1-x64.dmg
