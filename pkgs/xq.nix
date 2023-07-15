{ stdenv
, lib
, pkgs
}:

with pkgs; buildGo118Module rec {
  # https://github.com/sibprogrammer/xq/releases
  oname = "sibprogrammer";
  pname = "xq";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = oname;
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Z14x1b25wKNm9fECkNqGJglK/Z8Xq8VHmYfp5aEvvMU=";
  };

  vendorSha256 = "sha256-CP4QsrTkFcOLDxnFc0apevXRmXHA9aJSU4AK9+TAxOU=";

  meta.mainProgram = "xq";

  passthru.tests.version = testVersion { package = xq; command = "xq version"; };

  latest = "curl --location --silent 'https://api.github.com/repos/${oname}/${pname}/releases/latest' | jq -r '.tag_name' | tr -d v";
}
