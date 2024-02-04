{ stdenv
, lib
, pkgs
}:
with pkgs; stdenv.mkDerivation rec {
  name = "p0deje";
  uname = "maccy";
  aname = "Maccy";
  version = "0.29.4";

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
    sha256 = "sha256-6ltT2I7DFnkqf92zGftwiudEbdZ9dF221w1mPYZZKuI=";
  };

  latest = "curl --silent 'https://api.github.com/repos/${name}/${aname}/releases/latest' | jq -r '.tag_name'";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
