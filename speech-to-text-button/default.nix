# nix module
# expects home-manager to be setup
{
  pkgs
  , entryAfter # from home-manager flake.nix, lib.hm.dag.entryAfter
}:
let
  nerd-dictation = import ./nerd-dictation-pkg { inherit pkgs; };
  nerd-dictation-model = ./nerd-dictation-pkg/model.nix;

  speechToTextButton = import ./build.nix { inherit pkgs nerd-dictation; };
in
{
  home-manager.sharedModules = [
    # libvosk, vosk, nerd-dictation, and my executables in src/
    {
      home.packages = [ speechToTextButton ];
    }

    # desktop app to run hotkeys.py
    {
      config.xdg.desktopEntries = {
        speechToTextButton = {
          name = "Speech to Text Button";
          exec = "${speechToTextButton}/bin/hotkeys.py";
          terminal = true;
          comment = "Dictate your speech to text at the press of a button";
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
      home.activation.nerd-dictation-model = entryAfter [ "writeBoundary" ] ''
        mkdir -p $HOME/.config/nerd-dictation 2> /dev/null
        ln -sfn ${pkgs.callPackage nerd-dictation-model { }}/model $HOME/.config/nerd-dictation/model
      '';
    }
  ];
}
