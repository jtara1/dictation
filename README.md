# Dictation

[![FlakeHub](https://img.shields.io/endpoint?url=https://flakehub.com/f/jtara1/dictation/badge)](https://flakehub.com/flake/jtara1/dictation)

This enables you to dictate your speech to text and toggle to pause or resume it with the press of a hotkey.
Everything runs locally. This code helps build, download and load the model, add hotkeys, and run nerd-dictation.
This was specifically tested and built for x86_64-linux X11.

Packages several things:
- nerd-dictation
- nerd-dictation-model
- linux desktop app (`inputs.dictation.nixosModules.default`)
  - hotkeys.py
    - toggle-typing.sh

```text
$ nix flake show github:jtara1/dictation
github:jtara1/dictation/8dafb6e2a7aecf33f6698f0f1e64587ebf1c6695
├───nixosModules
│   └───default: NixOS module
└───packages
    └───x86_64-linux
        ├───nerd-dictation: package 'nerd-dictation'
        └───nerd-dictation-model: package 'nerd-dictation-model'
```

## Requirements

None if using or building through nix.

Each executable has its required packages, but these are installed through nix derivations I defined.

Some of the bigger models take several GB's on disk and **~5 GB memory**.

By default, `nerd-dictation-model` (and linux desktop app), uses a bigger model.

For other models, see https://alphacephei.com/vosk/models
and reference my `model.nix`.


## Install

### Flake

in your system flake,

```nix
  inputs = {
    # ...
    dictation.url = "github:jtara1/dictation";
    # if nixpkgs is defined here,
    dictation.inputs.nixpkgs.follows = "nixpkgs"; # where nixpkgs is your var for nixos nixpkgs in inputs
    # if home-manager is defined here,
    dictation.inputs.home-manager.follows = "home-manager"; # where home-manager is your var for home-manager in inputs
  };

  # ...
  # in outputs
  # in modules list, add entry, inputs.dictation.nixosModules.default
```

### Other

Download an exec [release](https://github.com/jtara1/dictation/releases) for your system.


## Usage

### Linux Desktop App

Search for and open `Dictation` desktop application.
This opens a terminal running hotkeys.py which can help you monitor the logs.


### Direct Usage

Everything is layered so you can choose your entrypoint.

Change the 2 files to executable `chmod +x myfile`, check their hashbangs.

```shell
cp hotkeys.py ..
cd ..
./hotkeys.py
```

If you don't want the global hotkeys, you can

```shell
./toggle-typing.sh # start
./toggle-typing.sh # pause
./toggle-typing.sh # resume
# ...
./toggle-typing.sh end # end
```

requires: bash, nerd-dictation, GNU screen

If you kill its screen session directly, it won't deallocate memory for the model resulting in a memory leak.

### Nix Run

#### Optionally build model derivation then link it
```shell
nix build 'github:jtara1/dictation#nerd-dictation-model'
src=$(nix path-info 'github:jtara1/dictation#nerd-dictation-model')
dst=~/.config/nerd-dictation/

mkdir -p ~/.config/nerd-dictation/
ln -sfn "$src"/model "$dst"/model
```

Alternatively, you can download, unpack, and move the model in place yourself.

#### Run nerd-dictation

```shell
nix run 'github:jtara1/dictation#nerd-dictation'
```


## Hotkeys

After hotkeys.py is executed,

| Hotkey           | description                                                           |
|------------------|-----------------------------------------------------------------------|
| ctrl + shift + ] | load model and start dictation or pause dictation or resume dictation |
| ctrl + shift + [ | end dictation deallocating memory taken by the model and libs         |

Default hotkeys are subject to change.


## TODO

These are improvements I thought of. I'm not necessarily planning on doing these.

`dictation/`
- [x] bundle my nix-build derivation to serve an executable for non-Nix systems
- [ ] test and fix usage on headless linux (TTY) - switch to using ydotool
- [x] test 1.0 release exec on fresh install of x86_64-linux (X11)
- [x] download and bundle a better model in the build of the store derivation
- [x] fix .desktop application - it's not linking to toggle-typing.sh correctly
- [x] absolute path for nerd-dictation and ./venv created by `nix-shell python.nix` and bundle nerd-dictation with nix module default.nix
- [x] python.nix (nix-shell) could build from my own derivation for nerd-dictation instead
- [ ] add build attribute to let the user choose which model to download and use
- [ ] avoid multiple processes running hotkeys.py - toggle-typing.sh should be multi-process safe as it should refer to the same screen session
- [ ] add build attributes to define custom hotkeys
- [ ] define word mapping for common words and phrases that aren't normally spoken (like "nix")
- [x] debug reason nerd-dictation dictating silence to "the" for me on silent idle -- (used an improved model for VOSK)
- [ ] better default hotkeys
- [x] package as a nix flake
- [ ] self-hosted server to run nerd-dictation with pulseaudio socket protocol changed to tcp?
- [ ] other projects and APIs that offer speech to text?


## References

This software is directly built on top of other software including:
- [nerd-dictation](https://github.com/ideasman42/nerd-dictation)
- [vosk-api (C lib and python module)](https://github.com/alphacep/vosk-api)
- [vosk models](https://alphacephei.com/vosk/models)
