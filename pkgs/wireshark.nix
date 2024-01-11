{ stdenv
, lib
, pkgs
}:
with pkgs; stdenv.mkDerivation rec {
  name = "wireshark";
  gname = "Wireshark";
  version = "4.2.1";

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
    sha256 = "sha256-NQgFF+BIp8p6P+gLiMn0RX6Lb5lIs8vrIskg+6zX4jQ=";
  };
  latest = "curl -s https://gitlab.com/api/v4/projects/7898047/repository/tags?order_by=version | jq -r '.[].name' | awk '!/rc/ {print $1;exit}' | sed -e 's/wireshark-//g'";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
