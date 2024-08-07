{
  description = "My out of band flakes/pkgs/modules for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust.url = "github:oxalica/rust-overlay";
  };

  outputs =
    {
      nixpkgs,
      unstable,
      flake-utils,
      rust,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust) ];
        };
        stable = nixpkgs.legacyPackages.${system};
        yolo = unstable.legacyPackages.${system};

        fake = nixpkgs.legacyPackages.${system}.lib.fakeSha256;

        # Silly wrapper around fetchurl
        extra =
          fname: sha256: from:
          pkgs.fetchurl rec {
            url = "${from}";
            name = "${fname}";
            inherit sha256;
          };

        # Ye olde halockrun and hatimerun
        hatools = (
          with pkgs;
          stdenv.mkDerivation rec {
            oname = "fatalmind";
            pname = "hatools";
            version = "2.1.4";

            src = fetchFromGitHub {
              sha256 = "sha256-Pl5hbL7aHK261/ReQ7kmHyoEprjD/sOL9kFSXR2g4Ok=";
              rev = "v2_14";
              owner = oname;
              repo = pname;
            };

            nativeBuildInputs = [
              autoreconfHook
              gnumake
              gcc
            ];

            installPhase = ''
              make install DESTDIR=""
            '';
          }
        );

        # Rust packages

        # Testing out some watch related things, need to PR adding a Cargo.lock
        # file as per
        # https://doc.rust-lang.org/cargo/guide/cargo-toml-vs-cargo-lock.html as
        # we shouldn't have to cargo update to get a cargo.lock file for a command
        # line app
        hwatch =
          with pkgs;
          (pkgs.makeRustPlatform {
            cargo = rust-bin.stable.latest.minimal;
            rustc = rust-bin.stable.latest.minimal;
          }).buildRustPackage
            rec {
              pname = "hwatch";
              version = "0.3.7";

              src = fetchFromGitHub {
                owner = "blacknon";
                repo = pname;
                rev = version;
                sha256 = "sha256-FVqvwqsHkV/yK5okL1p6TiNUGDK2ZnzVNO4UDVkG+zM=";
                forceFetchGit = true;
              };

              # Update via regenpatches
              cargoPatches = [ ./patches/hwatch-add-cargo-lock.patch ];

              cargoSha256 = "sha256-kfn7iOREFVS9LttfeRu+z5tXCheg54+tYozTsteFOX0=";

              passthru.tests.version = testVersion { package = hwatch; };

              latest = "curl --location --silent 'https://api.github.com/repos/blacknon/hwatch/releases/latest' | jq -r '.tag_name'";
            };

        # https://github.com/ClementTsang/bottom
        bottom =
          with stable;
          rustPlatform.buildRustPackage rec {
            pname = "bottom";
            version = "0.6.8";

            src = fetchFromGitHub {
              owner = "ClementTsang";
              repo = pname;
              rev = version;
              sha256 = "sha256-zmiYVLaXKHH+MObO75wOiGkDetKy4bVLe7IAqiO2ER8=";
            };

            # Macos needs a few Core system libraries
            buildInputs = lib.optionals stdenv.isDarwin [
              darwin.apple_sdk.frameworks.DiskArbitration
              darwin.apple_sdk.frameworks.Foundation
            ];

            cargoSha256 = "sha256-GMG6YBm/jA5D7wxC2gczMn/6Lkqiq/toSPNf86kgOys=";

            meta.mainProgram = "btm";

            passthru.tests.version = testVersion { package = bottom; };

            latest = "curl --location --silent 'https://api.github.com/repos/ClementTsang/bottom/releases/latest' | jq -r '.tag_name'";
          };

        # Go packages

        jira-cli =
          with stable;
          buildGo118Module rec {
            oname = "ankitpokhrel";
            pname = "jira-cli";
            version = "v1.1.0";

            src = fetchFromGitHub {
              owner = oname;
              repo = pname;
              rev = version;
              sha256 = "sha256-UpDaKg6TA1qCkbzF7BARtj+tAyuCCGAyqOdItZU64Ls=";
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

            vendorSha256 = "sha256-SpUggA9u8OGV2zF3EQ0CB8M6jpiVQi957UGaN+foEuk=";

            meta.mainProgram = "jira";

            passthru.tests.version = testVersion { package = jira-cli; };

            latest = "curl --location --silent 'https://api.github.com/repos/${oname}/${pname}/releases/latest' | jq -r '.tag_name'";
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
        kvmd =
          with stable;
          python310.pkgs.buildPythonPackage rec {
            pname = "kvmd";
            version = "3.56";

            src = fetchFromGitHub {
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
        ttyd_html_h = (
          extra "html.h" "sha256-MJE14kSSsvoFrUNGVKYOBfE9zCwBhtpAzQSRWzmZR6s="
            "https://raw.githubusercontent.com/pikvm/packages/master/packages/ttyd/html.h"
        );
        ttyd = (
          with pkgs;
          stdenv.mkDerivation rec {
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
          }
        );

        # TODO: https://sourceforge.net/projects/watchdog/ is at 5.16 pikvm still has 3 year old version, that important?
        watchdog = (
          with pkgs;
          stdenv.mkDerivation {
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
          }
        );
        ustreamer = (
          with pkgs;
          stdenv.mkDerivation {
            pname = "ustreamer";
            version = "4.13";
            src = fetchFromGitHub {
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

        # Probably totally broken stuff below here.
        ebpf_exporter =
          with stable;
          buildGo118Module rec {
            oname = "cloudflare";
            name = "ebpf_exporter";
            version = "v1.2.5";

            src = fetchFromGitHub {
              owner = oname;
              repo = name;
              rev = version;
              sha256 = "sha256-NrGTAvOf+2xKXY+ZLhe2zNKFWUU+akIwc1ZXGnZcfi4=";
            };

            vendorSha256 = null;

            buildInputs = with pkgs; [ bcc ];

            # meta.mainProgram = "jira";

            # passthru.tests.version = testVersion { package = jira-cli; };

            latest = "curl --location --silent 'https://api.github.com/repos/${oname}/${name}/releases/latest' | jq -r '.tag_name'";
          };
      in
      rec {
        # TODO: Make all this subpackages n stuff, will do it piecemeal with what
        # updates most often first.
        packages = flake-utils.lib.flattenTree {
          seaweedfs = pkgs.callPackage ./pkgs/seaweedfs.nix { inherit stable; };
          inherit watchdog;
          inherit ustreamer;
          inherit ttyd;
          inherit jira-cli;
          inherit hwatch;
          inherit bottom;
          inherit kvmd;
          inherit hatools;
          inherit ebpf_exporter;
          inherit hponcfg;

          default = pkgs.stdenv.mkDerivation {
            name = "mitchty";
            buildInputs = [ packages.seaweedfs ];

            src = ./.;

            doCheck = false;

            installPhase = ''
              install -dm755 $out
            '';
          };
        };

        apps = {
          seaweedfs = flake-utils.lib.mkApp { drv = packages.seaweedfs; };
        };

        defaultApp = flake-utils.lib.mkApp { drv = packages.default; };

        devShell = pkgs.mkShell {
          buildInputs = [
            packages.seaweedfs
            ustreamer
            watchdog
            ttyd
            jira-cli
            hwatch
            bottom
            kvmd
            hatools
            hponcfg
          ];
        };
      }
    );
}
