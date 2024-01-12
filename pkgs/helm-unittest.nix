{ stdenv
, lib
, pkgs
}:
pkgs.buildGoModule
rec {
  pname = "helm-unittest";
  version = "0.4.1";

  src = pkgs.fetchFromGitHub {
    owner = "helm-unittest";
    repo = "helm-unittest";
    rev = "v${version}";
    hash = "sha256-8rGYFoBhNPJnsZsRXJ7Z9a/KOV4d2ZIVLSdYCpf3IMs=";
  };

  vendorHash = "sha256-wD4FxJ/+8iw2qAz+s0G/8/PKt7X0MZn+roWtc/wTWmw=";

  ldflags = [ "-s" "-w" ];

  # Remove the plugin hooks we don't need em, change the binary to what the go
  # cmd build produces instead of whatever this default is.
  postPatch = ''
    sed -i '/^hooks:/,+2 d' plugin.yaml
    substituteInPlace plugin.yaml --replace untt bin/${pname}
  '';

  postInstall = ''
    install -dm755 $out/${pname}
    mv $out/bin $out/${pname}/
    install -m644 -Dt $out/${pname} plugin.yaml
  '';

  meta = with pkgs.lib; {
    description = "BDD styled unit test framework for Kubernetes Helm charts as a Helm plugin";
    homepage = "https://github.com/helm-unittest/helm-unittest";
    changelog = "https://github.com/helm-unittest/helm-unittest/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
  latest = "curl --location --silent 'https://api.github.com/repos/${pname}/${pname}/releases/latest' | jq -r '.tag_name' | tr -d v";
}
