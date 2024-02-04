{
  pkgs ? import <nixpkgs> {}
}:
let
  buildAttributes = {
    nativeBuildInputs = with pkgs; [ unzip wget ];
  };

  nerd-dictation-download-model = runCommand "nerd-dictation-download-model" buildAttributes ''
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
in nerd-dictation-download-model
