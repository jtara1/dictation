# nix module
# expects home-manager to be setup
{ pkgs, ... }:
let
  nerdDictationPkg = import ./nerd-dictation-pkg { inherit pkgs; };
  nerdDictationDownloadModel = ./nerd-dictation-pkg/download-model.nix;
  speechToTextBtnShell = import ./build-bundle.nix { inherit (pkgs) stdenv; };
in
{
  environment.systemPackages = [ pkgs.screen nerdDictationPkg ];

  home-manager.sharedModules = [
    # desktop app to run hotkeys.py
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

    # vosk model: link from file in store derivation to home config location for nerd-dictation
    {
      home.activationScripts.nerd-dictation-model = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p $HOME/.config/nerd-dictation 2> /dev/null
        ln -sfn ${pkgs.callPackage nerdDictationDownloadModel { }}/model $HOME/.config/nerd-dictation/model
      '';
    }
  ];
}
