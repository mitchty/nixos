{
  # Note: I'm going to fold all this junk into github/mitchty at some point
  # the split doesn't make much sense given my use cases.
  description = "My out of band flakes/pkgs/modules for NixOS/Darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    rust = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flakelight = {
      url = "github:nix-community/flakelight";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { flakelight, ... }@inputs:
    flakelight ./. rec {
      systems = [ "x86_64-linux" "x86_64-darwin" ];

      withOverlays = [
        inputs.rust.overlays.default
      ];
    };
}
