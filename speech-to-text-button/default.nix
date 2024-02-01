# nix module spec with custom arg, vars including vars.user
{ pkgs, vars, ... }:
let
  speechToTextBtnShell = import ./build-bundle.nix { inherit (pkgs) stdenv; };
in
{
  environment.systemPackages = [ pkgs.screen ];

  home-manager.users.${vars.user} = {
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
  };
}
