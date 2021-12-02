{
  description = "wip PiKVM flake/nixos port";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-21.11";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };
  outputs = { nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
      };
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
            mkdir -p $out/bin
            mv ustreamer $out/bin
          '';
        }
      );
    in rec {
      defaultApp = flake-utils.lib.mkApp {
        drv = defaultPackage;
      };
      defaultPackage = ustreamer;
      devShell = pkgs.mkShell {
        buildInputs = [
          ustreamer
        ];
      };
    }
  );
}
