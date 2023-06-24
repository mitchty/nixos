{ stdenv
, lib
, pkgs
}:

with pkgs; buildGo118Module rec {
  # https://github.com/sibprogrammer/xq/releases
  oname = "sibprogrammer";
  pname = "xq";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = oname;
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-bwyQ16E1M/vxwZQG472r0ZN7pVwZpb5wEot/Jt/Z6Ak=";
  };

  vendorSha256 = "sha256-5WLPLH8jsAQfx/OMJ9IZPPvqW0rXvnJf6PsFnVJH+CU=";

  meta.mainProgram = "xq";

  passthru.tests.version = testVersion { package = xq; command = "xq version"; };

  latest = "curl --location --silent 'https://api.github.com/repos/${oname}/${pname}/releases/latest' | jq -r '.tag_name' | tr -d v";
}
