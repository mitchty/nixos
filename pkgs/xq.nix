{ stdenv
, lib
, pkgs
}:

with pkgs; buildGoModule rec {
  oname = "sibprogrammer";
  pname = "xq";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = oname;
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-bhJ8zMZQZn/VzhulkfGOW+uyS8E43TIREAvKIsEPonA=";
  };

  vendorSha256 = "sha256-iJ1JMvIJqXLkZXuzn2rzKnLbiagTocg/6mJN3Pgd/4w=";

  meta.mainProgram = "xq";

  passthru.tests.version = testVersion { package = xq; command = "xq version"; };

  latest = "curl --location --silent 'https://api.github.com/repos/${oname}/${pname}/releases/latest' | jq -r '.tag_name' | tr -d v";
}
