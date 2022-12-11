{ stdenv
, lib
, pkgs
}:
with pkgs; stdenv.mkDerivation rec {
  name = "wireshark";
  gname = "Wireshark";
  version = "4.0.2";

  buildInputs = [ undmg ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    install -dm755 "$out/Applications"
    cp -r ${gname}.app "$out/Applications/${gname}.app"
  '';

  src = fetchurl {
    name = "${gname}.dmg";
    url = "https://2.na.dl.wireshark.org/osx/Wireshark%20${version}%20Intel%2064.dmg";
    sha256 = "sha256-nMjKL0iFgoXTUR8+XpFnrtz668XAbag2l2ak0taao34=";
  };
  latest = "curl --location --silent https://www.wireshark.org/#download | htmlq -wpt | awk '/current stable/ {print $8}' | sed 's/.$//'";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
