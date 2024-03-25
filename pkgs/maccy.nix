{ stdenv
, lib
, pkgs
}:
with pkgs; stdenv.mkDerivation rec {
  name = "p0deje";
  uname = "maccy";
  aname = "Maccy";
  version = "0.30.0";

  buildInputs = [ unzip ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    install -dm755 "$out/Applications"
    APP="$(echo *.app)"
    cp -rf "$APP" "$out/Applications/$(basename "$APP")"
  '';

  src = fetchurl {
    name = "${aname}.app.zip";
    url = "https://github.com/${name}/${aname}/releases/download/${version}/${aname}.app.zip";
    sha256 = "sha256-G6CDAiz+nfc8wfiku6PuIVsQ3wh1aeZhVGWgSdg7X5o=";
  };

  latest = "curl --silent 'https://api.github.com/repos/${name}/${aname}/releases/latest' | jq -r '.tag_name'";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
