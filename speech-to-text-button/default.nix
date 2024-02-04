# Nix module spec
# Expects home-manager to be setup
{ pkgs, ... }:
let
  speechToTextBtnShell = import ./build-bundle.nix { inherit (pkgs) stdenv; };
in
{
  environment.systemPackages = [ pkgs.screen ];

  home-manager.sharedModules = [
    {
      config.xdg.desktopEntries = {
        speechToTextButton = {
          name = "Speech to Text Button";
          exec = "${speechToTextBtnShell}/bin/hotkeys.py";
          terminal = true;
          comment = "Convert speech to text at the press of a button";
          categories = [ "Utility" ];
          type = "Application";
          settings = {
            SingleMainWindow = "true"; # this is only a suggestion, no logic change
          };
        };
      };
    }
  ];
}
