{ stdenv
, lib
, pkgs
}:
pkgs.buildGoModule
rec {
  pname = "helm-unittest";
  version = "0.3.0";

  src = pkgs.fetchFromGitHub {
    owner = "helm-unittest";
    repo = "helm-unittest";
    rev = "v${version}";
    hash = "sha256-B2JIurZ2PWmwAwdpE5Fjl5nsHgWasj6LvgPjmlOx4x4=";
  };

  vendorHash = "sha256-SIm9R+bUnLdVIFOI3456NDXKz8i04LSJLXoC25W0Llw=";

  ldflags = [ "-s" "-w" ];

  meta = with pkgs.lib; {
    description = "BDD styled unit test framework for Kubernetes Helm charts as a Helm plugin";
    homepage = "https://github.com/helm-unittest/helm-unittest";
    changelog = "https://github.com/helm-unittest/helm-unittest/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
