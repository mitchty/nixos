{ stdenv
, lib
, pkgs
, rust
, cargo
}:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "hwatch";
  version = "0.3.11";

  src = pkgs.fetchFromGitHub {
    owner = "blacknon";
    repo = pname;
    rev = version;
    sha256 = "sha256-S6hnmNnwdWd6iFM01K52oiKXiqu/0v5yvKKoeQMEqy0=";
    forceFetchGit = true;
  };

  cargoSha256 = "sha256-P4XkbV6QlokedKumX3UbCfEaAqH9VF9IKVyZIumZ6u0=";

  # passthru.tests.version = pkgs.testVersion {
  #   package = hwatch; };

  latest = "curl --location --silent 'https://api.github.com/repos/blacknon/hwatch/releases/latest' | jq -r '.tag_name'";
}
