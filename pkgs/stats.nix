{ stdenv
, lib
, pkgs
}:

with pkgs; stdenv.mkDerivation rec {
  name = "stats";
  uname = "exelban";
  aname = "Stats";
  version = "2.7.46";

  buildInputs = [ undmg ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    install -dm755 "$out/Applications"
    cp -r ${aname}.app "$out/Applications/${aname}.app"
  '';

  src = fetchurl {
    url = "https://github.com/${uname}/${name}/releases/download/v${version}/${aname}.dmg";
    sha256 = "sha256-x4aBPB4joZ/bYyTcVFvNYe8hSunEeE9Wj6MqeE9XTOc=";
  };

  latest = "curl --silent 'https://api.github.com/repos/exelban/stats/releases/latest' | jq -r '.tag_name' | tr -d v";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
