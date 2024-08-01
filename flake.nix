{
  # Note: I'm going to fold all this junk into github/mitchty at some point
  # the split doesn't make much sense given my use cases.
  description = "My out of band flakes/pkgs/modules for NixOS/Darwin";

  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/90f456026d284c22b3e3497be980b2e47d0b28ac";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    rust = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flakelight = {
      url = "github:nix-community/flakelight";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { flakelight, ... }@inputs:
    flakelight ./. rec {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
      ];

      withOverlays = [ (import inputs.rust) ];
    };
}
