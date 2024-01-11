{ stdenv
, lib
, pkgs
}:
with pkgs; stdenv.mkDerivation rec {
  name = "swiftbar";
  gname = "SwiftBar";
  version = "2.0.0";
  wtf = "b520";

  buildInputs = [ unzip ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    install -dm755 "$out/Applications"
    cp -r ${gname}.app "$out/Applications/${gname}.app"
  '';

  src = fetchurl {
    name = "${gname}.zip";
    url = "https://github.com/${name}/${gname}/releases/download/v${version}/${gname}.v${version}.${wtf}.zip";
    sha256 = "sha256-Ym2s0iEm3T2YIYkid+x/2vA5CVM0TcHYq1yqGr9nYrY=";
  };

  latest = "curl --silent 'https://api.github.com/repos/swiftbar/SwiftBar/releases/latest' | jq -r '.tag_name' | tr -d v";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
