{ stdenv
, lib
, pkgs
}:
with pkgs; stdenv.mkDerivation rec {
  name = "vlc";
  uname = "videolan";
  aname = "VLC";
  version = "3.0.17.3";

  buildInputs = [ undmg ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    install -dm755 "$out/Applications"
    cp -r ${aname}.app "$out/Applications/${aname}.app"
  '';

  src = fetchurl {
    name = "${aname}.dmg";
    url = "http://get.videolan.org/${name}/${version}/macosx/${name}-${version}-intel64.dmg";
    sha256 = "sha256-zKJn8sUa5WjgLztNimrbqHsr3l8BGiuHxZXBAtifEdg=";
  };

  latest = ''
    for tag in $(curl --silent 'https://api.github.com/repos/videolan/vlc/git/refs/tags' | jq -r '.[].ref' | sed -e 's|refs/tags/||' | grep -Ev '(dev|rc|git|pre|test|svn)' | sort -Vr); do
      if curl --fail -L -I http://get.videolan.org/vlc/$tag/macosx/vlc-$tag-intel64.dmg > /dev/null 2>&1; then
        printtf "%s" "$tag"
        break
      else
        printf "note: newer VLC version tag %s found but not present for download\n" "$tag" >&2
        printf "unknown"
      fi
    done
  '';

  meta = {
    platforms = [ "x86_64-darwin" ];
  };
}
