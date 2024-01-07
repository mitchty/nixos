{
  description = "My out of band flakes/pkgs/modules for NixOS/Darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    yolo.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust.url = "github:oxalica/rust-overlay";
  };

  # TODO: Future me, nuke flake-utils
  outputs = { nixpkgs, yolo, flake-utils, rust, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs-nixpkgs = import nixpkgs {
        inherit system;
        overlays = [
          (import rust)
        ];
      };

      pkgs-yolo = import yolo {
        inherit system;
        overlays = [
          (import rust)
        ];
      };

      pkgs = pkgs-nixpkgs;

      fake = nixpkgs.legacyPackages.${system}.lib.fakeSha256;

      # Silly wrapper around fetchurl
      extra = fname: sha256: from: pkgs.fetchurl rec {
        url = "${from}";
        name = "${fname}";
        inherit sha256;
      };

      buildInputsBase = [
        "altshfmt"
        "gh-actions-status"
        "hatools"
        "helm-unittest"
        "hwatch"
        "jira-cli"
        "no-more-secrets"
        "transcrypt"
        "xq"
      ];
      buildInputsDarwinX64 = [
        "clocker"
        "ferdium"
        "freetube"
        "hidden"
        "keepingyouawake"
        "maccy"
        "nheko"
        "notunes"
        "obs-studio"
        "vlc"
      ];
      buildInputsLinuxX64 = [
        "hponcfg"
      ];
      allBuildInputs = buildInputsBase ++ pkgs.lib.optionals (system == "x86_64-darwin") buildInputsDarwinX64 ++ pkgs.lib.optionals (system == "x86_64-linux") buildInputsLinuxX64;

    in
    rec {
      # TODO: Make all this subpackages n stuff, will do it piecemeal with what
      # updates most often first.
      packages = {
        altshfmt = pkgs.callPackage ./pkgs/altshfmt.nix { inherit pkgs; makeWrapper = pkgs.makeWrapper; };
        gh-actions-status = pkgs.callPackage ./pkgs/gh-actions-status.nix { inherit pkgs; };
        helm-unittest = pkgs.callPackage ./pkgs/helm-unittest.nix { inherit pkgs; };
        jira-cli = pkgs.callPackage ./pkgs/jira-cli.nix { inherit pkgs; };
        no-more-secrets = pkgs.callPackage ./pkgs/no-more-secrets.nix { inherit pkgs; };
        transcrypt = pkgs.callPackage ./pkgs/transcrypt.nix { fetchpatch = pkgs.fetchpatch; fetchFromGitHub = pkgs.fetchFromGitHub; git = pkgs.git; openssl = pkgs.openssl; coreutils = pkgs.coreutils; util-linux = pkgs.util-linux; gnugrep = pkgs.gnugrep; gnused = pkgs.gnused; gawk = pkgs.gawk; }; # Upstream nixpkgs is ancient vendor it in and pr if its ok.
      } // (pkgs.lib.optionalAttrs (system == "x86_64-darwin") {
        clocker = pkgs.callPackage ./pkgs/clocker.nix { inherit pkgs; };
        ferdium = pkgs.callPackage ./pkgs/ferdium.nix { inherit pkgs; };
        freetube = pkgs.callPackage ./pkgs/freetube.nix { inherit pkgs; };
        hidden = pkgs.callPackage ./pkgs/hidden.nix { inherit pkgs; };
        keepingyouawake = pkgs.callPackage ./pkgs/keepingyouawake.nix { inherit pkgs; };
        maccy = pkgs.callPackage ./pkgs/maccy.nix { inherit pkgs; };
        nheko = pkgs.callPackage ./pkgs/nheko.nix { inherit pkgs; };
        notunes = pkgs.callPackage ./pkgs/notunes.nix { inherit pkgs; };
        obs-studio = pkgs.callPackage ./pkgs/obs-studio.nix { inherit pkgs; };
        stats = pkgs.callPackage ./pkgs/stats.nix { inherit pkgs; };
        stretchly = pkgs.callPackage ./pkgs/stretchly.nix { inherit pkgs; };
        swiftbar = pkgs.callPackage ./pkgs/swiftbar.nix { inherit pkgs; };
        vlc = pkgs.callPackage ./pkgs/vlc.nix { inherit pkgs; };
        wireshark = pkgs.callPackage ./pkgs/wireshark.nix { inherit pkgs; };
      }) // (pkgs.lib.optionalAttrs (system == "x86_64-linux") {
        hponcfg = pkgs.callPackage ./pkgs/hponcfg.nix { fetchurl = pkgs.fetchurl; rpmextract = pkgs.rpmextract; openssl = pkgs.openssl; busybox = pkgs.busybox; autoPatchelfHook = pkgs.autoPatchelfHook; makeWrapper = pkgs.makeWrapper; };
      }) // flake-utils.lib.flattenTree {
        hwatch = pkgs.callPackage ./pkgs/hwatch.nix { inherit pkgs; };

        hatools = pkgs.callPackage ./pkgs/hatools.nix { inherit pkgs; };
        xq = pkgs.callPackage ./pkgs/xq.nix { inherit pkgs; };

        default = pkgs.stdenv.mkDerivation {
          name = "mitchty";
          buildInputs = pkgs.lib.attrsets.attrVals allBuildInputs packages;
          src = ./.;

          doCheck = false;

          installPhase = ''
            install -dm755 $out
          '';
        };
      };

      apps = {
        altshfmt = flake-utils.lib.mkApp { drv = packages.altshfmt; };
        gh-actions-status = flake-utils.lib.mkApp { drv = packages.hatools; };
        hatools = flake-utils.lib.mkApp { drv = packages.hatools; };
        helm-unittest = flake-utils.lib.mkApp { drv = packages.helm-unittest; };
        hwatch = flake-utils.lib.mkApp { drv = packages.hwatch; };
        jira-cli = flake-utils.lib.mkApp { drv = packages.jira-cli; };
        transcrypt = flake-utils.lib.mkApp { drv = packages.transcrypt; };
        xq = flake-utils.lib.mkApp { drv = packages.xq; };
      } // (pkgs.lib.optionalAttrs (system == "x86_64-darwin") {
        clocker = flake-utils.lib.mkApp { drv = packages.clocker; };
        ferdium = flake-utils.lib.mkApp { drv = packages.ferdium; };
        freetube = flake-utils.lib.mkApp { drv = packages.freetube; };
        hidden = flake-utils.lib.mkApp { drv = packages.hidden; };
        keepingyouawake = flake-utils.lib.mkApp { drv = packages.keepingyouawake; };
        maccy = flake-utils.lib.mkApp { drv = packages.maccy; };
        nheko = flake-utils.lib.mkApp { drv = packages.nheko; };
        notunes = flake-utils.lib.mkApp { drv = packages.notunes; };
        obs-studio = flake-utils.lib.mkApp { drv = packages.obs-studio; };
        stats = flake-utils.lib.mkApp { drv = packages.stats; };
        stretchly = flake-utils.lib.mkApp { drv = packages.stretchly; };
        swiftbar = flake-utils.lib.mkApp { drv = packages.swiftbar; };
        vlc = flake-utils.lib.mkApp { drv = packages.vlc; };
        wireshark = flake-utils.lib.mkApp { drv = packages.wireshark; };
      }) // (pkgs.lib.optionalAttrs (system == "x86_64-linux") {
        hponcfg = flake-utils.lib.mkApp { drv = packages.hponcfg; };
      });

      defaultApp = flake-utils.lib.mkApp {
        drv = packages.default;
      };

      # TODO: This is deprecated according to nix flake check replace at some point.
      devShell = pkgs.mkShell
        {
          buildInputs = pkgs.lib.attrsets.attrVals allBuildInputs packages;
        };
      checks = {
        nixpkgs-fmt = pkgs.runCommand "check-nix-format" { } ''
          ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${./.}
          install -dm755 $out
        '';
        versions = pkgs.runCommand "check-versions" { } ''
          export PATH="${nixpkgs.lib.makeBinPath [pkgs.coreutils pkgs.curl pkgs.jq pkgs.htmlq]}:$PATH"
          DIR=${./.} sh ${./bin/versions}
          install -dm755 $out
        '';
      };
    }
  );
}
