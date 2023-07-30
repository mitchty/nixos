{ stdenv
, lib
, pkgs
, rust
, cargo
}:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "hwatch";
  version = "0.3.10";

  src = pkgs.fetchFromGitHub {
    owner = "blacknon";
    repo = pname;
    rev = version;
    sha256 = "sha256-RvsL6OajXwEY77W3Wj6GMijYwn7XDnKiJyDXbNG01ag=";
    forceFetchGit = true;
  };

  cargoSha256 = "sha256-v7MvXnc9Xa+6QAyi2N9/WtqnvXf9M1SlR86kNjfu46Y=";

  # passthru.tests.version = pkgs.testVersion {
  #   package = hwatch; };

  latest = "curl --location --silent 'https://api.github.com/repos/blacknon/hwatch/releases/latest' | jq -r '.tag_name'";
}
