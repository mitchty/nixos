{
  description = "My out of band flakes/pkgs/modules for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, unstable, flake-utils, ... }:  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
      };
      p = nixpkgs.legacyPackages.${system};
      u = unstable.legacyPackages.${system};

      fake = p.lib.fakeSha256;

      # Silly wrapper around fetchurl
      extra = fname: sha256: from: pkgs.fetchurl rec {
        url = "${from}";
        name = "${fname}";
        inherit sha256;
      };

      # Ye olde halockrun and hatimerun
      hatools = (with pkgs; stdenv.mkDerivation {
        pname = "hatools";
        version = "2.1.4";

        src = fetchFromGitHub {
          sha256 = "sha256-Pl5hbL7aHK261/ReQ7kmHyoEprjD/sOL9kFSXR2g4Ok=";
          rev = "v2_14";
          owner = "fatalmind";
          repo = "hatools";
        };

        nativeBuildInputs = [
          autoreconfHook
          gnumake
          gcc
        ];

        installPhase = ''
          make install DESTDIR=""
        '';
      });

      # Rust packages

      # s3 filesystem provider like minio
      garage = p.rustPlatform.buildRustPackage rec {
        pname = "garage";
        version = "0.6.1";

        src = p.fetchFromGitea {
          domain = "git.deuxfleurs.fr";
          owner = "Deuxfleurs";
          repo = pname;
          rev = "v" + version;
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
        version = "0.3.4";

        src = p.fetchFromGitHub {
          owner = "blacknon";
          repo = pname;
          rev = version;
          sha256 = "sha256-I8i7lyD//vLGU2BcKMf2h5qydV6LRefzYcgBFxLbFCg=";
          forceFetchGit = true;
        };

        # Update via:
        # gh blacknon/hwatch
        # git fetch
        # git co $version
        # cargo update
        # git add -f Cargo.lock
        # git diff --cached > ~/src/pub/github.com/mitchty/nixos/patches/hwatch-add-cargo-lock.patch
        # fill out new cargosha256 and cross fingies
        cargoPatches = [
          ./patches/hwatch-add-cargo-lock.patch
        ];

        cargoSha256 = "sha256-MFhjugbkNYQ7TigM+ihyquAgHRBFOJnvPJWZ4GlrqRY=";

        passthru.tests.version = p.testVersion { package = hwatch; };

        latest = "curl --silent 'https://api.github.com/repos/blacknon/hwatch/releases/latest' | jq -r '.tag_name'";
      };

      # https://github.com/ClementTsang/bottom
      bottom = p.rustPlatform.buildRustPackage rec {
        pname = "bottom";
        version = "0.6.8";

        src = p.fetchFromGitHub {
          owner = "ClementTsang";
          repo = pname;
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
      seaweedfs = u.buildGo118Module rec {
        pname = "seaweedfs";
        version = "2.99";

        src = p.fetchFromGitHub {
          owner = "chrislusf";
          repo = pname;
          rev = version;
          sha256 = "sha256-PexO7I7l4GCFkViZpgjOkDrM05quANRR9o+lKFTG5PE=";
        };

        vendorSha256 = "sha256-gfgjbG+QeyIY/vTAZkvZj6ODUD96Y6omGwM2tJG8HCw=";

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
      #
      # Picking back up from this commit for now
      # https://github.com/pikvm/packages/tree/fa1982ec7db49ee66a5429919738cd9e0c16587b/packages
      #
      # TODO: Get this building and deps, bit of a stub for now
      # TODO: The arch package does a *LOT* of things this won't do that we'll relegate to a nixos module
      # like ensuring certain sysctl's are set etc.... users blah blah blah
      #
      # Also todo is ssl certs that nixos module should make ssl certs easy peasy lemon whatever
      #
      # TODO: Figure out if its better to just build janus-gateway here with these overrides or not:
      # https://github.com/pikvm/packages/blob/fa1982ec7db49ee66a5429919738cd9e0c16587b/packages/janus-gateway-pikvm/PKGBUILD#L57-L65
      kvmd = p.python310.pkgs.buildPythonPackage rec {
        pname = "kvmd";
        version = "3.56";

        src = p.fetchFromGitHub {
          sha256 = "sha256-D+Dyg9tjjrTvBlLRBOnJKUc2/RT5zJFdqldY/RaSpzU=";
          rev = "v3.56";
          owner = "pikvm";
          repo = pname;
        };

        # TODO: unit tests fail, figure out how to let them pass if possible
        doCheck = false;

        propagatedBuildInputs = with pkgs; [
          freetype
          libgpiod
          nginx
          openssl
          platformio
          janus-gateway
          ustreamer
          zstd
          ipmitool
          avrdude
          v4l_utils
        ];
      };
      ttyd_html_h = (extra "html.h" "sha256-MJE14kSSsvoFrUNGVKYOBfE9zCwBhtpAzQSRWzmZR6s=" "https://raw.githubusercontent.com/pikvm/packages/master/packages/ttyd/html.h");
      ttyd = (with pkgs; stdenv.mkDerivation {
        pname = "ttyd";
        version = "1.6.3";

        src = fetchFromGitHub {
          sha256 = "sha256-Oj43XLohq7lyK6gq7YJDwdOWbTveNqX4vKE5X1M75eA=";
          rev = "47c554323a00c413996c6db4df9cf6dde6e2f574";
          owner = "tsl0922";
          repo = pname;
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

      # TODO: https://sourceforge.net/projects/watchdog/ is at 5.16 pikvm still has 3 year old version, that important?
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
        version = "4.13";
        src = p.fetchFromGitHub {
          owner = "pikvm";
          repo = "ustreamer";
          rev = "v4.13";
          sha256 = "sha256-otiBdGHQLjYE8/FDJUZzcU+f9ZfkPRtXQ0EBVa4Ogcw=";
          fetchSubmodules = true;
        };

        nativeBuildInputs = [
          gnumake
          gcc
          libevent
          libjpeg
          libbsd
        ];

        # TODO: rpi related work for OMX/GPIO as per https://github.com/pikvm/ustreamer#building
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
        inherit watchdog;
        inherit ustreamer;
        inherit ttyd;
        inherit seaweedfs;
        inherit garage;
        inherit hwatch;
        inherit bottom;
        inherit kvmd;
        inherit hatools;
      };

      defaultApp = flake-utils.lib.mkApp {
        drv = defaultPackage;
      };
      devShell = pkgs.mkShell {
        buildInputs = [
          ustreamer
          watchdog
          ttyd
          seaweedfs
          garage
          hwatch
          bottom
          kvmd
          hatools
        ];
      };
      # dummy for now until I package the other bajillion things
      defaultPackage = seaweedfs;
    }
  );
}
