{ stdenv
, lib
, pkgs
, rust
, cargo
}:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "hwatch";
  version = "0.3.13";

  src = pkgs.fetchFromGitHub {
    owner = "blacknon";
    repo = pname;
    rev = version;
    sha256 = "sha256-3RFiVDXjPFBMK+f/9s9t3cdIH+R/88Fp5uKbo5p2X+g=";
    forceFetchGit = true;
  };

  cargoSha256 = "sha256-MC0Ch9ai4XmhhRz/9nFYEA3A7kgBv2x9q4yc5IJ7CZ8=";

  # passthru.tests.version = pkgs.testVersion {
  #   package = hwatch; };

  latest = "curl --location --silent 'https://api.github.com/repos/blacknon/hwatch/releases/latest' | jq -r '.tag_name'";
}
