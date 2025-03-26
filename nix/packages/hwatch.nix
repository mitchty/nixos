{ stdenv
, lib
, pkgs
, rust
, cargo
,
}:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "hwatch";
  version = "0.3.15";

  src = pkgs.fetchFromGitHub {
    owner = "blacknon";
    repo = pname;
    rev = version;
    sha256 = "sha256-UmNxdp9acRCKnUsKw7Z9z3knRvVkqQ5atxR/dqpGBYE=";
    forceFetchGit = true;
  };

  cargoHash = "sha256-pEhogmK2WBj/PxcDtJs/H0XZhPiz3zCQMX2eUcAfnTE=";

  # passthru.tests.version = pkgs.testVersion {
  #   package = hwatch; };

  latest = "curl --location --silent 'https://api.github.com/repos/blacknon/hwatch/releases/latest' | jq -r '.tag_name'";
}
