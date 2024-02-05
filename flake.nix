{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    entryAfter = home-manager.lib.hm.dag.entryAfter;
  in {
    packages.${system} = {
      nerd-dictation = import ./dictation/nerd-dictation { inherit pkgs; };
      nerd-dictation-model = import ./dictation/nerd-dictation/model.nix { inherit pkgs; };
    };

    nixosModules.default = { pkgs, ... }: {
      imports = [
        (import ./dictation/desktop-app.nix { inherit pkgs entryAfter; })
      ];
    };
  };
}
