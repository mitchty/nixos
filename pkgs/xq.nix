{ stdenv
, lib
, pkgs
}:

with pkgs; buildGo118Module rec {
  # https://github.com/sibprogrammer/xq/releases
  oname = "sibprogrammer";
  pname = "xq";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = oname;
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-XZ6YKHXNt+L2TWTQj6annPGrM33xg/n5Ci4N/28BvJY=";
  };

  vendorSha256 = "sha256-HI+6A027yvHb/ZyXdt/pRSdmYbNYXGrkmZ4EFb4MqXc=";

  meta.mainProgram = "xq";

  passthru.tests.version = testVersion { package = xq; command = "xq version"; };

  latest = "curl --location --silent 'https://api.github.com/repos/${oname}/${pname}/releases/latest' | jq -r '.tag_name' | tr -d v";
}
