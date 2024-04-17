{ stdenv
, lib
, pkgs
}:

with pkgs; stdenv.mkDerivation rec {
  pname = "google-chrome";
  aname = "Stats";
  version = "107.0.5304.110";

  src = fetchurl {
    url = "https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg";
    sha256 = "sha256-IBc508+UHTPa9gU1EWDyK91YdwcCZ+K0LzfvpmE3h3I=";
  };

  buildInputs = [ undmg ];
  sourceRoot = "${aname}.app";

  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    install -dm755 "$out/Applications/${aname}.app"
    cp -r . "$out/Applications/${aname}.app"
  '';

  latest = "curl --silent 'https://api.github.com/repos/exelban/stats/releases/latest' | jq -r '.tag_name' | tr -d v";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
