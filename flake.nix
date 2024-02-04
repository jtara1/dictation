{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager }:
  let
    entryAfter = home-manager.lib.hm.dag.entryAfter;
  in
  {
    nixosModules.default = { pkgs, ... }:
    {
      imports = [
        (import ./dictation/desktop-app.nix { inherit pkgs entryAfter; })
      ];
    };
  };
}
