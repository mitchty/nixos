{ stdenv
, lib
, pkgs
}:
with pkgs; stdenv.mkDerivation rec {
  name = "obs-studio";
  uname = "obsproject";
  aname = "OBS";
  version = "30.0.0";

  sourceRoot = ".";
  phases = [ "installPhase" ];
  installPhase = ''
    set -x
    install -dm755 "$out/Applications"
    VOLUME=$(/usr/bin/hdiutil attach -nobrowse $src | awk '/Volumes/ { print substr($0, index($0,$3)) }')
    trap "/usr/bin/hdiutil detach \"$VOLUME\"" EXIT INT HUP TERM
    APP=$(${pkgs.findutils}/bin/find "$VOLUME" -maxdepth 1 -name '*.app')
    cp -rf "$APP" "$out/Applications/$(basename \"$APP\").app"
  '';

  src = fetchurl {
    name = "${aname}.dmg";
    # As of obs 28.0.0 this disk image is now APFS and not HFS, so undmg no worky
    url = "https://github.com/${uname}/${name}/releases/download/${version}/OBS-Studio-${version}-macos-Intel.dmg";
    sha256 = "sha256-NnsSKZp8ImuAFxCL0lEJOvUN/i2GprCqpUGAodpj9lc=";
  };

  latest = "curl --silent 'https://api.github.com/repos/obsproject/obs-studio/releases/latest' | jq -r '.tag_name'";

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
