{ stdenv
, lib
, pkgs
}:
with pkgs; stdenv.mkDerivation rec {
  name = "stretchly";
  uname = "hovancik";
  aname = "Stretchly";
  version = "1.13.1";

  buildInputs = [ undmg ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    install -dm755 "$out/Applications"
    cp -r ${aname}.app "$out/Applications/${aname}.app"
  '';

  src = fetchurl {
    # https://github.com/hovancik/stretchly/releases/download/v1.10.0/Stretchly-1.10.0.dmg
    url = "https://github.com/${uname}/${name}/releases/download/v${version}/${aname}-${version}.dmg";
    sha256 = "sha256-LyK2POX4vQWwJIIYua9VVVNZAdKih/2JalrigRlpduU=";
  };

  latest = "curl --silent 'https://api.github.com/repos/hovancik/stretchly/releases/latest' | jq -r '.tag_name' | tr -d v";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
