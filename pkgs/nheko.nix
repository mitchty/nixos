{ stdenv
, lib
, pkgs
}:
with pkgs; stdenv.mkDerivation rec {
  name = "nheko";
  uname = "Nheko-Reborn";
  aname = "Nheko";
  version = "0.10.2";

  buildInputs = [ undmg ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    install -dm755 "$out/Applications"
    cp -r ${aname}.app "$out/Applications/${aname}.app"
  '';

  src = fetchurl {
    name = "${aname}.dmg";
    url = "https://github.com/${uname}/${name}/releases/download/v${version}/${name}-v${version}.dmg";
    sha256 = "sha256-1VS/vCcfWHazeaB8BsX12M1feB77ufj6G0SoHVnV+4E=";
  };

  latest = "curl --silent 'https://api.github.com/repos/${uname}/${name}/releases/latest' | jq -r '.tag_name' | tr -d v";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
