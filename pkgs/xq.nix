{ stdenv
, lib
, pkgs
}:

with pkgs; buildGoModule rec {
  oname = "sibprogrammer";
  pname = "xq";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = oname;
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Zg1ARyDXklKBR5WhqRakWT/KcG5796h2MxsBjPCWSjs=";
  };

  vendorHash = "sha256-NNhndc604B0nGnToS7MtQzpn3t3xPl5DlkCafc/EyKE=";

  meta.mainProgram = "xq";

  passthru.tests.version = testVersion { package = xq; command = "xq version"; };

  latest = "curl --location --silent 'https://api.github.com/repos/${oname}/${pname}/releases/latest' | jq -r '.tag_name' | tr -d v";
}
