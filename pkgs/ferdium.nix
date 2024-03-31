{ stdenv
, lib
, pkgs
}:
with pkgs; stdenv.mkDerivation rec {
  name = "ferdium";
  uname = "ferdium";
  aname = "Ferdium";
  version = "6.7.2";

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
    sha256 = "sha256-5DwQX6zeA/L/2dw0TrkcaI+y5x9HeAw7Pcjs6w20onA=";
  };

  latest = "curl --silent 'https://api.github.com/repos/${uname}/${name}-app/releases/latest' | jq -r '.tag_name' | tr -d v";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
