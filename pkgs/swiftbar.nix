{ stdenv
, lib
, pkgs
}:
with pkgs; stdenv.mkDerivation rec {
  name = "swiftbar";
  gname = "SwiftBar";
  version = "1.4.3";

  buildInputs = [ unzip ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    install -dm755 "$out/Applications"
    cp -r ${gname}.app "$out/Applications/${gname}.app"
  '';

  src = fetchurl {
    name = "${gname}.zip";
    url = "https://github.com/${name}/${gname}/releases/download/v${version}/${gname}.zip";
    sha256 = "sha256-IP/lWahb0ouG912XvaWR3nDL1T3HrBZ2E8pp/WbHGgQ=";
  };

  latest = "curl --silent 'https://api.github.com/repos/swiftbar/SwiftBar/releases/latest' | jq -r '.tag_name' | tr -d v";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
