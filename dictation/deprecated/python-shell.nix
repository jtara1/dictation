# description: helps create a shell which has the required pkgs bundled to run nerd-dictation
# run: $ nix-shell python-shell.nix
with import <nixpkgs> { };
let
  pythonPackages = python3Packages;
in pkgs.mkShell rec {
  name = "speech-to-text-python-env";
  venvDir = "/tmp/speech-to-text-python-venv";
  buildInputs = [
    # A Python interpreter including the 'venv' module is required to bootstrap
    # the environment.
    pythonPackages.python

    # This execute some shell code to initialize a venv in $venvDir before
    # dropping into the shell
    pythonPackages.venvShellHook

    # Those are dependencies that we would like to use from nixpkgs, which will
    # add them to PYTHONPATH and thus make them accessible from within the venv.
    # can add python pkgs here too

    xdotool # nerd-dictation (optionally for sending keyboard input - X11)
#    ydotool # nerd-dictation (optionally for sending keyboard input - X11, Wayland, TTY)
    pulseaudio
#    sox # nerd-dictation (optionally as alt to pulseaudio for audio input, see https://github.com/ideasman42/nerd-dictation/blob/main/readme-sox.rst)
#    pavucontrol # nerd-dictation (optionally as volume control & helps see devices)
#    lame # nerd-dictation (optionally as helping process mp3)

    # nativeBuildInputs
    curl
    wget
    unzip
  ];

  # Run this command, only after creating the virtual environment
  postVenvCreation = ''
    pip install vosk
  '';

  # runs even if venv is already created
  preShellHook = ''
    unset SOURCE_DATE_EPOCH

    # enables local imports using absolute python modules source the $PWD eg: import my_module.my_submodule.my_lib
    export PYTHONPATH="$PYTHONPATH:$PWD"

    # required by numpy
    export LD_LIBRARY_PATH="${lib.getLib zlib}/lib"

    # required by vosk which relies on libvosk.so which links libstdc++.so.6
    export LD_LIBRARY_PATH="${lib.getLib stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH"
  '';

  # Now we can execute any commands within the virtual environment.
  # This is optional and can be left out to run pip manually.
  postShellHook = ''
    # allow pip to install wheels
    unset SOURCE_DATE_EPOCH

    # nerd-dictation should be bundled already
#    if [ ! -f nerd-dictation ]; then
#      curl --silent \
#        --output /tmp/nerd-dictation \
#        'https://raw.githubusercontent.com/ideasman42/nerd-dictation/main/nerd-dictation'
#
#      chmod +x /tmp/nerd-dictation
#    fi

    # for other models, see
    # https://alphacephei.com/vosk/models
    if [ ! -e ~/.config/nerd-dictation/model ]; then
      mkdir -p ~/.config/nerd-dictation
      pushd ~/.config/nerd-dictation

#      model=vosk-model-small-en-us-0.15.zip
#      model=vosk-model-en-us-0.22.zip
      model=vosk-model-en-us-0.42-gigaspeech.zip

      wget https://alphacephei.com/kaldi/models/$model
      unzip $model

      mv "''${model%.zip}" model

      popd
    fi
  '';
}
