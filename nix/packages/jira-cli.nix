{
  stdenv,
  lib,
  pkgs,
}:
pkgs.buildGoModule rec {
  oname = "ankitpokhrel";
  pname = "jira-cli";
  version = "1.5.1";

  src = pkgs.fetchFromGitHub {
    owner = oname;
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-edytj9hB8lDwy3qGSyLudu5G4DSRGKhD0vDoWz5eUgs=";
  };

  # For a rather contrived test in the test suite that uses this...
  # https://github.com/ankitpokhrel/jira-cli/blob/55d0d33dc0879c743445451b5c22e69c06383a16/pkg/tui/helper.go#L58
  # But that function mixes up runtime configuration assumptions (e.g.
  # less/more etc..) exist at runtime with what its testing:
  # https://github.com/ankitpokhrel/jira-cli/blob/main/pkg/tui/helper_test.go#L89-L101
  #
  # Instead of bothering trying to make an environment that will conform
  # to its expectations just skip testing the pager stuff.
  postPatch = ''
    substituteInPlace pkg/tui/helper_test.go --replace "TestGetPager" "SkipTestGetPager"
  '';

  nativeBuildInputs = [ pkgs.less ];

  vendorHash = "sha256-DAdzbANqr0fa4uO8k/yJFoirgbZiKOQhOH8u8d+ncao=";

  meta.mainProgram = "jira";

  # TODO: figure out how to pas this in...
  # passthru.tests.version = pkgs.testVersion { package = ; };

  latest = "curl --location --silent 'https://api.github.com/repos/${oname}/${pname}/releases/latest' | jq -r '.tag_name' | tr -d v";
}
