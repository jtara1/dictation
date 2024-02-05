# Dictation

This enables you to dictate your speech to text and toggle to pause or resume it with the press of a hotkey.
Everything runs locally. This code helps build, download and load model, add hotkeys, and run nerd-dictation.
This was specifically tested on NixOS x86_64-linux X11.


## Requirements

Each executable has its required packages, but these are installed through nix derivations I defined.

By default, I'm loading a bigger model than their default which takes several GB's on disk and **~5 GB memory**.

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
    dictation.inputs.nixpkgs.follows = "nixpkgs"; # where nixpkgs is a var for nixos nixpkgs in inputs
    # if home-manager is defined here,
#    dictation.inputs.home-manager.follows = "home-manager"; # where home-manager is a var for home-manager in inputs
  };
  
  # ...
  # outputs = { self, nixpkgs, ... } @ inputs: { nixosConfigurations.my-pc-hostname.nixpkgs.lib.nixosSystem { modules = [ ]; }; };
  # in modules list, add entry, inputs.dictation.nixosModules.default
```

### Other

I should be able to bundle this with `nix bundle` to just drop an executable on other computers.


## Usage

### Linux Desktop App

Search for and open `Dictation` desktop application.
This opens a terminal running hotkeys.py which can help you monitor the logs, stdout, stderr.

Most linux desktop environments should have support for this. I've created an entry for this executable as
a .desktop config.

### Direct Usage

I haven't tested this much and don't support it, but it should work with some effort.

Everything is layered so you can choose your entrypoint.

Change the 2 files to executable `chmod +x myfile`, check their hashbangs.

```shell
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


## Hotkeys

After hotkeys.py is executed,

| Hotkey   | description                                                           |
|----------|-----------------------------------------------------------------------|
| ctrl + ] | load model and start dictation or pause dictation or resume dictation |
| ctrl + [ | end dictation deallocating memory taken by the model and libs         |

I'm open to suggestions for better default hotkeys.


## TODO

These are improvements I thought of. I'm not necessarily planning on doing these.

`dictation/`
- [ ] bundle my nix-build derivation to serve an executable for non-Nix systems
- [ ] test and fix usage on headless linux (TTY)
- [x] download and bundle a better model in the build of the store derivation
- [x] fix .desktop application - it's not linking to toggle-typing.sh correctly
- [x] absolute path for nerd-dictation and ./venv created by `nix-shell python.nix` and bundle nerd-dictation with nix module default.nix
- [x] python.nix (nix-shell) could build from my own derivation for nerd-dictation instead
- [ ] test this on a fresh install running x86 64 linux with X11 running NixOS
- [ ] add build attribute to let the user choose which model to download and use
- [ ] avoid multiple processes running hotkeys.py - toggle-typing.sh should be multi-process safe as it should refer to the same screen session
- [ ] add build attributes to define custom hotkeys
- [ ] define word mapping for common words and phrases that aren't normally spoken (like "nix")
- [x] debug reason nerd-dictation dictating silence to "the" for me on silent idle -- (used an improved model for VOSK)
- [ ] better default hotkeys
- [x] package as a nix flake
- [ ] self-hosted server to run nerd-dictation with pulseaudio socket protocol changed to tcp?

`nerd-dictation/`
- [x] define nix runCommand or wrap nerd-dictation defining `--vosk-model-dir=some/nix/path/model` appending args added by the user for use with nerd-dictation or patch it in a more hacky way?
- [x] add home-manager as a dep in the build or add a systemd service to create ~/.config/nerd-dictation/model, download, unzip model before runtime for runtime?


## Alternatives

These options can only be used in certain contexts or applications.

### Web API

This uses a remote relay server to process audio for speech to text. If you run chromium or chrome, you can use
my prototype https://tarasoft.pro/speech-to-text.html

It's about <100 lines of HTML and JS.

You permit audio permission request via your browser for the web page/site, speak, copy and paste your text.

### Android Gboard

Press the mic button. Probably uses a remote relay server to process your audio.


## Sources

This software is directly built on top of other software including:
- [nerd-dictation](https://github.com/ideasman42/nerd-dictation)
- [vosk-api (C lib and python module)](https://github.com/alphacep/vosk-api)
- [vosk models](https://alphacephei.com/vosk/models)
