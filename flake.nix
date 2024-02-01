{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    devShellBundleDrv = import ./speech-to-text-button/build-bundle.nix { inherit (pkgs) stdenv; };
  in
  {
    packages.${system}.default = devShellBundleDrv;

    nixosModules.default = { config, pkgs, pkgsUnstable ? null, lib, ... }:
    {
      options = {};
      config = {
        home-manager.users.j = {
          config.xdg.desktopEntries = {
            speechToTextButton = {
              name = "Speech to Text Button";
              exec = "${devShellBundleDrv}/bin/hotkeys.py";
              terminal = true;
              comment = "Convert speech to text at the press of a button";
              categories = [ "Utility" ];
              type = "Application";
              settings = {
                SingleMainWindow = "true"; # this is only a suggestion, no logic change
              };
            };
          };
        };
      };
    };
  };
}
