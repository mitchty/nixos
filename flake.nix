{
  description = "My out of band flakes/pkgs/modules for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
      };
      p = nixpkgs.legacyPackages.${system};
      # Silly wrapper around fetchurl
      extra = fname: sha256: from: pkgs.fetchurl rec {
        url = "${from}";
        name = "${fname}";
        inherit sha256;
      };

      # Rust packages

      # s3 filesystem provider like minio
      garage = p.rustPlatform.buildRustPackage rec {
        pname = "garage";
        version = "0.6.0";

        src = p.fetchFromGitea {
          domain = "git.deuxfleurs.fr";
          owner = "Deuxfleurs";
          repo = "garage";
          rev = "v${version}";
          sha256 = "sha256-NNjqDOkMMRyXce+Z7RQpuffCuVhA1U3qH30rSv939ks=";
        };

        cargoSha256 = "sha256-eKJxRcC43D8qVLORer34tlmsWhELTbcJbZLyf0MB618=";

        passthru = {
          tests.version = p.testVersion { package = garage; };
        };
      };

      # Testing out some watch related things, need to PR adding a Cargo.lock
      # file as per
      # https://doc.rust-lang.org/cargo/guide/cargo-toml-vs-cargo-lock.html as
      # we shouldn't have to cargo update to get a cargo.lock file for a command
      # line app
      hwatch = p.rustPlatform.buildRustPackage rec {
        pname = "hwatch";
        version = "0.3.3";

        src = p.fetchFromGitHub {
          owner = "blacknon";
          repo = "hwatch";
          rev = version;
          sha256 = "sha256-fJM9MYaGmwT3zVaxRjecfCzfXw+Gjwf73DSoOchucoE=";
          forceFetchGit = true;
        };

        cargoPatches = [
          ./patches/hwatch-add-cargo-lock.patch
        ];

        cargoSha256 = "sha256-CvZNy4cGeFDO/pFQv8Gc5AvUDtMU1ZLTSsajO2CxZxY=";

        passthru.tests.version = p.testVersion { package = hwatch; };
      };

      # Go packages

      # Like minio, will test/compare this with garage ^^^ to see which works better
      seaweedfs = p.buildGo117Module rec {
        pname = "seaweedfs";
        version = "2.90";

        src = p.fetchFromGitHub {
          owner = "chrislusf";
          repo = "seaweedfs";
          rev = version;
          sha256 = "sha256-PZe/yUJGcj3/nIYaf7eAbiJIA2YASJ8nlMLIWWKJrbo=";
        };

        vendorSha256 = "sha256-E6bMpWzXb5dMPXkrVSJJWXJYvkmI3cNRseMgrQNpCl4=";

        subPackages = [ "weed" ];

        postInstall = ''
          install -dm755 $out/sbin
          ln -sf $out/bin/weed $out/sbin/mount.weed
        '';

        passthru.tests.version =
          p.testVersion { package = seaweedfs; command = "weed version"; };
      };

      # PiKVM related (incomplete)
      ttyd_html_h = (extra "html.h" "sha256-MJE14kSSsvoFrUNGVKYOBfE9zCwBhtpAzQSRWzmZR6s=" "https://raw.githubusercontent.com/pikvm/packages/master/packages/ttyd/html.h");
      ttyd = (with pkgs; stdenv.mkDerivation {
        pname = "ttyd";
        version = "1.6.3";
        src = fetchFromGitHub {
          sha256 = "sha256-Oj43XLohq7lyK6gq7YJDwdOWbTveNqX4vKE5X1M75eA=";
          rev = "47c554323a00c413996c6db4df9cf6dde6e2f574";
          owner = "tsl0922";
          repo = "ttyd";
        };
        preBuild = ''
          install -m644 ${ttyd_html_h} html.h
        '';
        nativeBuildInputs = [
          cmake
          gnumake
          gcc
          libwebsockets
          zlib
          libuv
          json_c
          libpcap
          openssl
        ];
        installPhase = ''
          make install DESTDIR=""
        '';
      });
      watchdog = (with pkgs; stdenv.mkDerivation {
        pname = "watchdog";
        version = "5.15";
        src = fetchgit {
          url = "https://git.code.sf.net/p/watchdog/code";
          rev = "03d67da";
          sha256 = "sha256-ZLLObroUWcdGPP4jpbR7IMHx0Yj4uUY6al0ztE2k5bI=";
          fetchSubmodules = true;
        };
        nativeBuildInputs = [
          autoreconfHook
          pkg-config
          gnumake
          gcc
        ];
        # The config file uses DESTDIR in its install setup for a file in /etc
        postPatch = ''
          sed -ie "s/DESTDIR/PREFIX/" Makefile.am
        '';
        configureFlags = [
          "--with-pidfile=/run/watchdog.pid"
          "--with-ka_pidfile=/run/wd_keepalive.pid"
          "--disable-nfs"
        ];
        buildPhase = ''
          make -j $NIX_BUILD_CORES
        '';
        postInstall = ''
          ln -s $out/sbin $out/bin
        '';
        installPhase = ''
          make install DESTDIR="" PREFIX=$out
        '';
      });
      ustreamer = (with pkgs; stdenv.mkDerivation {
        pname = "ustreamer";
        version = "4.10";
        src = fetchgit {
          url = "https://github.com/pikvm/ustreamer";
          rev = "v4.10";
          sha256 = "sha256-Wn19J3CvRQPG6KogDeZXO5Xb+jNZdEQBzmR/0bGfO6A=";
          fetchSubmodules = true;
        };
        nativeBuildInputs = [
          gnumake
          gcc
          libevent
          libjpeg
          libbsd
        ]; # TODO: rpi related work for OMX/GPIO as per https://github.com/pikvm/ustreamer#building
        buildPhase = "make -j $NIX_BUILD_CORES";
        installPhase = ''
          install -dm755 $out/bin
          install -m755 src/ustreamer.bin $out/bin/ustreamer
        '';
      }
      );
    in
    rec {
      packages = flake-utils.lib.flattenTree {
        inherit watchdog ustreamer ttyd seaweedfs garage hwatch;
        # inherit watchdog ustreamer ttyd seaweedfs;
      };
      defaultApp = flake-utils.lib.mkApp {
        drv = defaultPackage;
      };
      devShell = pkgs.mkShell {
        buildInputs = [ ustreamer watchdog ttyd seaweedfs garage hwatch ];
      };
      # dummy for now until I package the other bajillion things
      defaultPackage = seaweedfs;
    }
  );
}
