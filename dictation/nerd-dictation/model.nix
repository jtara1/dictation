# build: $ nix-build -o result --verbose model.nix
# check: $ file ./result/model
{
  pkgs ? import <nixpkgs> {}
}:
let
  inherit (pkgs) stdenv fetchurl;

  nerd-dictation-model = stdenv.mkDerivation {
    name = "nerd-dictation-model";
    pname = "nerd-dictation-model";

    src = fetchurl {
      url = "https://alphacephei.com/kaldi/models/vosk-model-en-us-0.42-gigaspeech.zip";
      hash = "sha256-1nVcmbC8j7PFaWJpDcVel5Kr2SVQ3aC4iZ8X2lW/PzA=";
    };

    nativeBuildInputs = with pkgs; [ unzip ];

    unpackPhase = "unzip $src";
    installPhase = ''
      mkdir -p $out/model
      mv vosk-model-en-us-0.42-gigaspeech $out/model
    '';
  };
in nerd-dictation-model
