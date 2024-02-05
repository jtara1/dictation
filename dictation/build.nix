# build: $ nix-build -o result --verbose build.nix
# run: $ ./result/bin/hotkeys.py
{
  pkgs ? import <nixpkgs> {}
  , nerd-dictation ? import ./nerd-dictation {}
}:
with pkgs;
let
  dictation = python3Packages.buildPythonPackage {
    pname = "dictation_hotkeys";
    version = "1.0";

    src = ./src;

    propagatedBuildInputs = with python3Packages; [ pynput ];

    postInstall = ''
      mkdir -p $out/lib

      cp dictation_hotkeys/hotkeys.py $out/lib/
      chmod +x $out/lib/hotkeys.py

      cp toggle-typing.sh $out/lib/
      chmod +x $out/lib/toggle-typing.sh

      wrapProgram $out/lib/toggle-typing.sh --prefix PATH : ${lib.makeBinPath [ nerd-dictation pkgs.screen ]}
    '';

    meta = {
      description = "Press a button, computer types what you speak";
      maintainers = [ "jtara1" ];
      license = lib.licenses.asl20;
    };
  };
in dictation
