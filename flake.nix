{
  description = "My out of band flakes/pkgs/modules for NixOS/Darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust.url = "github:oxalica/rust-overlay";
  };

  # TODO: Future me, nuke flake-utils
  outputs = { nixpkgs, unstable, flake-utils, rust, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (import rust)
        ];
      };
      stable = nixpkgs.legacyPackages.${system};
      yolo = unstable.legacyPackages.${system};

      fake = nixpkgs.legacyPackages.${system}.lib.fakeSha256;

      # Silly wrapper around fetchurl
      extra = fname: sha256: from: pkgs.fetchurl rec {
        url = "${from}";
        name = "${fname}";
        inherit sha256;
      };

      # Rust packages

      # Testing out some watch related things, need to PR adding a Cargo.lock
      # file as per
      # https://doc.rust-lang.org/cargo/guide/cargo-toml-vs-cargo-lock.html as
      # we shouldn't have to cargo update to get a cargo.lock file for a command
      # line app
      hwatch = with pkgs; (pkgs.makeRustPlatform {
        cargo = rust-bin.stable.latest.minimal;
        rustc = rust-bin.stable.latest.minimal;
      }).buildRustPackage rec {
        pname = "hwatch";
        version = "0.3.9";

        src = fetchFromGitHub {
          owner = "blacknon";
          repo = pname;
          rev = version;
          sha256 = "sha256-O+qKVRPDn7y8JEAF75P6suH4hOfPLjWSNTDGX2V5z3w=";
          forceFetchGit = true;
        };

        # Update via regenpatches
        cargoPatches = [
          ./patches/hwatch-add-cargo-lock.patch
        ];

        cargoSha256 = "sha256-fO+80nAwSnFsNM/81qLWN2YU55Lk4SKbLpSBQS0WJUo=";

        passthru.tests.version = testVersion { package = hwatch; };

        latest = "curl --location --silent 'https://api.github.com/repos/blacknon/hwatch/releases/latest' | jq -r '.tag_name'";
      };

    in
    rec {
      # TODO: Make all this subpackages n stuff, will do it piecemeal with what
      # updates most often first.
      packages = {
        altshfmt = pkgs.callPackage ./pkgs/altshfmt.nix { pkgs = stable; makeWrapper = pkgs.makeWrapper; };
        # Upstream nixpkgs is ancient vendor it in and pr if its ok.
        transcrypt = pkgs.callPackage ./pkgs/transcrypt.nix { fetchFromGitHub = pkgs.fetchFromGitHub; git = pkgs.git; openssl = pkgs.openssl; coreutils = pkgs.coreutils; util-linux = pkgs.util-linux; gnugrep = pkgs.gnugrep; gnused = pkgs.gnused; gawk = pkgs.gawk; };
        helm-unittest = pkgs.callPackage ./pkgs/helm-unittest.nix { pkgs = stable; };
        jira-cli = pkgs.callPackage ./pkgs/jira-cli.nix { pkgs = stable; };
      } // (pkgs.lib.optionalAttrs (system == "x86_64-darwin") {
        nheko = pkgs.callPackage ./pkgs/nheko.nix { pkgs = stable; };
        obs-studio = pkgs.callPackage ./pkgs/obs-studio.nix { pkgs = stable; };
        stats = pkgs.callPackage ./pkgs/stats.nix { pkgs = stable; };
        stretchly = pkgs.callPackage ./pkgs/stretchly.nix { pkgs = stable; };
        swiftbar = pkgs.callPackage ./pkgs/swiftbar.nix { pkgs = stable; };
        vlc = pkgs.callPackage ./pkgs/vlc.nix { pkgs = stable; };
        wireshark = pkgs.callPackage ./pkgs/wireshark.nix { pkgs = stable; };
      }) // (pkgs.lib.optionalAttrs (system == "x86_64-linux") {
        hponcfg = pkgs.callPackage ./pkgs/hponcfg.nix { fetchurl = pkgs.fetchurl; rpmextract = stable.rpmextract; openssl = pkgs.openssl; busybox = pkgs.busybox; autoPatchelfHook = pkgs.autoPatchelfHook; makeWrapper = pkgs.makeWrapper; };
      }) // flake-utils.lib.flattenTree {
        inherit hwatch;

        hatools = pkgs.callPackage ./pkgs/hatools.nix { pkgs = stable; };
        xq = pkgs.callPackage ./pkgs/xq.nix { pkgs = stable; };

        default = pkgs.stdenv.mkDerivation {
          name = "mitchty";
          buildInputs = [
            packages.altshfmt
            packages.hatools
            hwatch
            packages.jira-cli
            packages.helm-unittest
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
        hatools = flake-utils.lib.mkApp { drv = packages.hatools; };
        hwatch = flake-utils.lib.mkApp { drv = packages.hwatch; };
        jira-cli = flake-utils.lib.mkApp { drv = packages.jira-cli; };
        helm-unittest = flake-utils.lib.mkApp { drv = packages.helm-unittest; };
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
          hwatch
          packages.altshfmt
          packages.hatools
          packages.helm-unittest
          packages.jira-cli
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
