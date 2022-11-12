{ stdenv
, lib
, pkgs
}:
# Like minio...ish
# TODO: Get this building again on macos, some weird cgo things going on with go-ieproxy
# Leaving not working efforts inline for future me to know what doesn't work.
with pkgs; buildGo118Module rec {
  # https://github.com/sibprogrammer/xq/releases
  oname = "sibprogrammer";
  pname = "xq";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = oname;
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-EJ7byYl3VoflbNH0JFbr1zWWNVXpioN3yKwCEzSmVGc=";
  };

  vendorSha256 = "sha256-9XvXoXwebs6TRlfxXidiRkQLzgZYkDo8o/a4A0SO26s=";

  meta.mainProgram = "xq";

  passthru.tests.version = testVersion { package = xq; command = "xq version"; };

  latest = "curl --location --silent 'https://api.github.com/repos/${oname}/${pname}/releases/latest' | jq -r '.tag_name'";
}
