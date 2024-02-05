# nix module
# expects home-manager to be setup
{
  pkgs
  , entryAfter # from home-manager flake.nix, lib.hm.dag.entryAfter
}:
let
  nerd-dictation = import ./nerd-dictation { inherit pkgs; };
  nerd-dictation-model = ./nerd-dictation/model.nix;

  dictation = import ./build.nix { inherit pkgs nerd-dictation; };
in
{
  environment.systemPackages = [ dictation ];

  home-manager.sharedModules = [
    # libvosk, vosk, nerd-dictation, and my executables in src/
#    {
#      home.packages = [ dictation ];
#    }

    # desktop app to run hotkeys.py
    {
      config.xdg.desktopEntries = {
        dictation = {
          name = "Dictation";
          exec = "${dictation}/lib/hotkeys.py";
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
