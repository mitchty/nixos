{ stdenv
, lib
, pkgs
}:
pkgs.buildGoModule
rec {
  pname = "helm-unittest";
  version = "0.4.0";

  src = pkgs.fetchFromGitHub {
    owner = "helm-unittest";
    repo = "helm-unittest";
    rev = "v${version}";
    hash = "sha256-jS25CQZvHtJ/A3A+dSHew5LbgzlynYvO7ml0QL6h1ns=";
  };

  vendorHash = "sha256-iVHweO/lVJ8fkc3HoY/jnGxclSGwbNLn9WiWh61zYKo=";

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
