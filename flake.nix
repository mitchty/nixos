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
        version = "0.6.1";

        src = p.fetchFromGitea {
          domain = "git.deuxfleurs.fr";
          owner = "Deuxfleurs";
          repo = "garage";
          rev = "v${version}";
          sha256 = "sha256-BEFxPU4yPtctN7H+EcxJpXnf4tyqBseskls0ZA9748k=";
        };

        cargoSha256 = "sha256-/mOH7VOfIHEydnJUUSts44aGb8tS1/Faxiu4pQDeobY=";

        passthru.tests.version = p.testVersion { package = garage; };

        latest = "curl --header 'Accept: application/json' --silent 'https://git.deuxfleurs.fr/api/v1/repos/Deuxfleurs/garage/releases' | jq -r '.[0].tag_name' | tr -d v";
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

        latest = "curl --silent 'https://api.github.com/repos/blacknon/hwatch/releases/latest' | jq -r '.tag_name'";
      };

      # https://github.com/ClementTsang/bottom
      bottom = p.rustPlatform.buildRustPackage rec {
        pname = "bottom";
        version = "0.6.8";

        src = p.fetchFromGitHub {
          owner = "ClementTsang";
          repo = "bottom";
          rev = version;
          sha256 = "sha256-zmiYVLaXKHH+MObO75wOiGkDetKy4bVLe7IAqiO2ER8=";
        };

        # Macos needs a few Core system libraries
        buildInputs = p.lib.optionals p.stdenv.isDarwin [
          p.darwin.apple_sdk.frameworks.DiskArbitration
          p.darwin.apple_sdk.frameworks.Foundation
        ];

        cargoSha256 = "sha256-GMG6YBm/jA5D7wxC2gczMn/6Lkqiq/toSPNf86kgOys=";

        meta.mainProgram = "btm";

        passthru.tests.version = p.testVersion { package = bottom; };

        latest = "curl --silent 'https://api.github.com/repos/ClementTsang/bottom/releases/latest' | jq -r '.tag_name'";
      };

      # Go packages
      # Like minio, will test/compare this with garage ^^^ to see which works better
      seaweedfs = p.buildGo117Module rec {
        pname = "seaweedfs";
        version = "2.95";

        src = p.fetchFromGitHub {
          owner = "chrislusf";
          repo = pname;
          rev = version;
          sha256 = "sha256-nnu2a9nODmuRSk2CkD170yVNG2c7BM97tbJT5R+dN3E=";
        };

        vendorSha256 = "sha256-k2851Mb0xVRxoL+s6/W6MAJYTYO/UV/UXh5DrvH74JA=";

        subPackages = [ "weed" ];

        postInstall = ''
          install -dm755 $out/sbin
          ln -sf $out/bin/weed $out/sbin/mount.weed
        '';

        meta.mainProgram = "weed";

        passthru.tests.version = p.testVersion { package = seaweedfs; command = "weed version"; };

        latest = "curl --silent 'https://api.github.com/repos/chrislusf/seaweedfs/releases/latest' | jq -r '.tag_name'";
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
        inherit watchdog ustreamer ttyd seaweedfs garage hwatch bottom;
        # inherit watchdog ustreamer ttyd seaweedfs;
      };
      defaultApp = flake-utils.lib.mkApp {
        drv = defaultPackage;
      };
      devShell = pkgs.mkShell {
        buildInputs = [ ustreamer watchdog ttyd seaweedfs garage hwatch bottom ];
      };
      # dummy for now until I package the other bajillion things
      defaultPackage = seaweedfs;
    }
  );
}
