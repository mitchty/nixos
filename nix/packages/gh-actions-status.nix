{
  stdenv,
  lib,
  pkgs,
}:
pkgs.buildGoModule rec {
  oname = "rsese";
  pname = "gh-actions-status";
  version = "1.3.1";

  src = pkgs.fetchFromGitHub {
    owner = oname;
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Wly+GH3bHS8pDh6Vs1xSK09e5MbZsb+2xuaMKdQaIUc=";
  };

  vendorHash = "sha256-cUjY1yhkH1I2AT4iuLTTneRkgtjSFauWeBUxTzwa200=";

  patches = [ ../../patches/gh-actions-status-go-deps.patch ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
  ];

  # the binary gets built as actions-dashboard so move it to gh-actions-status
  # instead so gh can run it.
  postInstall = ''
    mv $out/bin/actions-dashboard $out/bin/gh-actions-status
  '';

  latest = "curl --location --silent 'https://api.github.com/repos/${oname}/${pname}/releases/latest' | jq -r '.tag_name' | tr -d v";
}
