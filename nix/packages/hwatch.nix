{ stdenv
, lib
, pkgs
, rust
, cargo
}:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "hwatch";
  version = "0.3.12";

  src = pkgs.fetchFromGitHub {
    owner = "blacknon";
    repo = pname;
    rev = version;
    sha256 = "sha256-Klv1VIJv4/R7HvvB6H+WxTeJxQYFqAFU3HC6oafD/90=";
    forceFetchGit = true;
  };

  cargoSha256 = "sha256-Aos/QP8tLiKFmAZss19jn5h/murZR2jgTYRYalUONHw=";

  # passthru.tests.version = pkgs.testVersion {
  #   package = hwatch; };

  latest = "curl --location --silent 'https://api.github.com/repos/blacknon/hwatch/releases/latest' | jq -r '.tag_name'";
}
