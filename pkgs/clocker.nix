{ stdenv
, lib
, pkgs
}:
with pkgs; stdenv.mkDerivation rec {
  name = "n0shake";
  uname = "clocker";
  aname = "Clocker";
  version = "23.01";

  buildInputs = [ unzip ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    install -dm755 "$out/Applications"
    APP="$(echo *.app)"
    cp -rf "$APP" "$out/Applications/$(basename "$APP")"
  '';

  src = fetchurl {
    name = "${aname}.zip";
    url = "https://github.com/${name}/${uname}/releases/download/${version}/${aname}.zip";
    sha256 = "sha256-a9P1U/zZ4S3WVgUzBUUK60GRITCy9l0IVxjJqnDK4Kg=";
  };

  latest = "curl --silent 'https://api.github.com/repos/${name}/${uname}/releases/latest' | jq -r '.tag_name'";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
#https://github.com/n0shake/clocker/releases/download/23.01/Clocker.zip
