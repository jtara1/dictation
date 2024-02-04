{
  pkgs ? import <nixpkgs> {}
}:
let
  inherit (pkgs) stdenv fetchurl;

  buildAttributes = {
    nativeBuildInputs = with pkgs; [ unzip wget ];
  };

  nerd-dictation-model = stdenv.mkDerivation {
    name = "nerd-dictation-model";
    pname = "nerd-dictation-model";

    src = fetchurl {
      url = "https://alphacephei.com/kaldi/models/vosk-model-en-us-0.42-gigaspeech.zip";
      sha256 = "sha256-1nVcmbC8j7PFaWJpDcVel5Kr2SVQ3aC4iZ8X2lW/PzA=";
    };

    nativeBuildInputs = with pkgs; [ unzip ];

    unpackPhase = "unzip $src";
    installPhase = ''
      mkdir -p $out/model
      mv vosk-model-en-us-0.42-gigaspeech $out/model

      rm vosk-model-en-us-0.42-gigaspeech
      rm vosk-model-en-us-0.42-gigaspeech.zip
    '';
  };

  nerd-dictation-download-model = pkgs.runCommand "nerd-dictation-download-model" buildAttributes ''
    # for other models, see
    # https://alphacephei.com/vosk/models
#    model=vosk-model-small-en-us-0.15.zip # default for $ nerd-dictation begin
#    model=vosk-model-en-us-0.22.zip
    model=vosk-model-en-us-0.42-gigaspeech.zip

    # fetch
    wget https://alphacephei.com/kaldi/models/$model
    # unpack
    unzip $model

    # install
    mkdir -p $out/model
    mv "''${model%.zip}" $out/model

    # fixup
    rm $model
  '';
in nerd-dictation-model
