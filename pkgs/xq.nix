{ stdenv
, lib
, pkgs
}:

with pkgs; buildGoModule rec {
  oname = "sibprogrammer";
  pname = "xq";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = oname;
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-g1d5sS3tgxP2VRogWG/5OXezDsJuQ6e724te+Oj3r24=";
  };

  vendorHash = "sha256-Oy/BBE6qCKJQRNDn6UiBr+/Psgi3A9Eaytmbmjt7eq8=";

  meta.mainProgram = "xq";

  passthru.tests.version = testVersion { package = xq; command = "xq version"; };

  latest = "curl --location --silent 'https://api.github.com/repos/${oname}/${pname}/releases/latest' | jq -r '.tag_name' | tr -d v";
}
