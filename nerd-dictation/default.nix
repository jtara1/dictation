# build: $ nix-build -o result --verbose
# run: $ ./result/bin/nerd-dictation begin
let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib stdenv fetchurl fetchgit python3Packages;

  libvosk = stdenv.mkDerivation {
    name = "libvosk";
    pname = "libvosk";

    src = fetchurl {
      url = "https://github.com/alphacep/vosk-api/releases/download/v0.3.45/vosk-linux-x86_64-0.3.45.zip";
      sha256 = "sha256-u9yO2FxDl59kQxQoiXcOqVy/vFbP+1xdzXOvqHXF+7I=";
    };

    nativeBuildInputs = with pkgs; [ unzip ];
    unpackPhase = "
      unzip $src
    ";

    installPhase = ''
      mkdir -p $out/lib
      mv vosk-linux-x86_64-0.3.45/* $out/lib
      rm -r vosk-linux-x86_64-0.3.45/
    '';
  };

  vosk = python3Packages.buildPythonPackage {
    pname = "vosk";
    version = "0.3.45";
    format = "setuptools";

    src = fetchgit {
      url = "https://github.com/alphacep/vosk-api";
      sparseCheckout = [
        # FIXME: why isn't this pulling src/ from the repo? I need to create and add to src/ manually during configurePhase
        "src"
        "python"
      ];
      hash = "sha256-7TxyvfgGkFOrt/HnLWAILuRaVkTlWL+nP7+dRt++7OE=";
    };

    nativeBuildInputs = [ stdenv.cc ];
    propagatedBuildInputs = [
      python3Packages.cffi python3Packages.requests python3Packages.srt python3Packages.websockets
      python3Packages.tqdm
      # ideally I'd just add this here and it would work :) C lib in python via FFI and explicit paths make it tricky?
      # should python FFI be looking in /usr/local/include and /usr/local/lib ?
      libvosk
    ];

    patches = [
      ./vosk-setup.py.patch
    ];

    configurePhase = ''
      mkdir src/
      # hack: put things in places like their module expects - python setup is moving C header and C lib to unique places
      cp ${libvosk}/lib/vosk_api.h src/
      cp ${libvosk}/lib/libvosk.so python/vosk/
    '';

    preBuild = "cd python";
    doCheck = false;
  };

  nerd-dictation = stdenv.mkDerivation {
    name = "nerd-dictation";
    pname = "nerd-dictation";

    src = fetchgit {
      url = "https://github.com/ideasman42/nerd-dictation";
      sparseCheckout = [ "nerd-dictation" ];
      hash = "sha256-rZo662A3wEVGYK7pq7Z3lh2yP0WJoLeMM4VpEG2QqY0";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];
    propagatedBuildInputs = [
      (python3Packages.python.withPackages (p: [ vosk ]))
      pkgs.xdotool
      pkgs.pulseaudio
    ];

    preInstall = ''
      mkdir -p "$out/bin"
      cp nerd-dictation $out/bin/
      chmod +x $out/bin/nerd-dictation
    '';

    postFixup = ''
      wrapProgram $out/bin/nerd-dictation \
        --set PATH ${lib.makeBinPath [
          pkgs.xdotool
          pkgs.pulseaudio
        ]}
    '';
  };
in nerd-dictation
