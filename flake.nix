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
        transcrypt = pkgs.callPackage ./pkgs/transcrypt.nix { fetchFromGitHub = pkgs.fetchFromGitHub; git = pkgs.git; openssl = pkgs.openssl; coreutils = pkgs.coreutils; util-linux = pkgs.util-linux; gnugrep = pkgs.gnugrep; gnused = pkgs.gnused; gawk = pkgs.gawk; }; # Upstream nixpkgs is ancient vendor it in and pr if its ok.
      } // (pkgs.lib.optionalAttrs (system == "x86_64-darwin") {
        nheko = pkgs.callPackage ./pkgs/nheko.nix { inherit pkgs; };
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
          buildInputs = [
            packages.altshfmt
            packages.gh-actions-status
            packages.hatools
            packages.helm-unittest
            packages.hwatch
            packages.jira-cli
            packages.no-more-secrets
            packages.transcrypt
            packages.xq
          ] ++ pkgs.lib.optionals (system == "x86_64-darwin") [
            packages.nheko
            packages.obs-studio
            packages.stats
            packages.stretchly
            packages.swiftbar
            packages.vlc
            packages.wireshark
          ] ++ pkgs.lib.optionals (system == "x86_64-linux") [
            packages.hponcfg
          ];

          src = ./.;

          doCheck = false;

          installPhase = ''
            install -dm755 $out
          '';
        };
      };

      apps = {
        gh-actions-status = flake-utils.lib.mkApp { drv = packages.hatools; };
        hatools = flake-utils.lib.mkApp { drv = packages.hatools; };
        helm-unittest = flake-utils.lib.mkApp { drv = packages.helm-unittest; };
        hwatch = flake-utils.lib.mkApp { drv = packages.hwatch; };
        jira-cli = flake-utils.lib.mkApp { drv = packages.jira-cli; };
        transcrypt = flake-utils.lib.mkApp { drv = packages.transcrypt; };
        xq = flake-utils.lib.mkApp { drv = packages.xq; };
      } // (pkgs.lib.optionalAttrs (system == "x86_64-darwin") {
        nheko = flake-utils.lib.mkApp { drv = packages.nheko; };
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
      devShell = pkgs.mkShell {
        # Macos only stuff is mostly just diskimages no devShell shenanigans
        # needed.
        buildInputs = [
          packages.altshfmt
          packages.gh-actions-status
          packages.hatools
          packages.helm-unittest
          packages.hwatch
          packages.jira-cli
          packages.no-more-secrets
          packages.transcrypt
          packages.xq
        ] ++ pkgs.lib.optionals (system == "x86_64-darwin") [
          packages.nheko
          packages.obs-studio
          packages.stats
          packages.stretchly
          packages.swiftbar
          packages.vlc
          packages.wireshark
        ] ++ pkgs.lib.optionals (system == "x86_64-linux") [
          packages.hponcfg
        ];
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
