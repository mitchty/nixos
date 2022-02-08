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
      seaweedfs = p.buildGo117Module rec {
          pname = "seaweedfs";
          version = "2.88";

          src = p.fetchFromGitHub {
            owner = "chrislusf";
            repo = "seaweedfs";
            rev = version;
            sha256 = "0c5j5swsi8vxn34n2hjia5zylarg49h638zj5i95dnmw0sx1ry07";
          };

          vendorSha256 = "sha256-p52YtA8U6xsi9upVZyoXjMce2v5bH3DkaRFZhq6MMeY=";

          subPackages = [ "weed" ];

          postInstall = ''
            install -dm755 $out/sbin
            ln -sf $out/bin/weed $out/sbin/mount.weed
          '';

          passthru.tests.version =
            p.testVersion { package = seaweedfs; command = "weed version"; };
      };
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
        inherit watchdog ustreamer ttyd seaweedfs;
      };
      defaultApp = flake-utils.lib.mkApp {
        drv = defaultPackage;
      };
      devShell = pkgs.mkShell {
        buildInputs = [ ustreamer watchdog ttyd seaweedfs ];
      };
      # dummy for now until I package the other bajillion things
      defaultPackage = seaweedfs;
    }
  );
}
