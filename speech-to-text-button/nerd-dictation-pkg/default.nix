# build: $ nix-build -o result --verbose
# run: $ ./result/bin/nerd-dictation begin
{
  pkgs ? import <nixpkgs> {}
}:
let
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
      rev = "cf2560c9f8a49d3d366b433fdabd78c518231bec";
      sparseCheckout = [
        "src"
        "python"
      ];
      hash = "sha256-hVQJNZSNhpw+BdOkZDqDVlRg6feK5OjR0ks7DizrBeE=";
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
