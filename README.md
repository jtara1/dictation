# Speech to Text Button

This enables you to the do speech to text typing and toggle to pause or resume it with the press of a hotkey.
Everything runs locally. This code helps build, bundle, download and load model, add hotkeys, and run nerd-dictation.
This was specifically tested on NixOS x86_64-linux X11.


## Requirements

```shell
chmod +x hotkeys.py
chmod +x toggle-typing.sh
```

I'm loading a bigger model in python.nix than the default which takes several GB's on disk and ~5 GB memory.

### Packages

- bash
- screen
- nix-shell


## Usage

Everything is layered so you can choose your entrypoint.

### Direct usage with global hotkeys

```shell
cd speech-to-text-button
./hotkeys.py
```

requires: nix-shell and deps of toggle-typing.sh

### Direct usage toggling dictation manually

If you don't want the global hotkeys, you can

```shell
cd speech-to-text-button
./toggle-typing.sh # start
./toggle-typing.sh # pause
./toggle-typing.sh # resume
# ...
./toggle-typing.sh end # end
```

requires: bash, nix-shell, GNU screen

If you kill its screen session directly, it won't deallocate memory for the model resulting in a memory leak.

### speech-to-text-button.desktop

Search for and open `Speech to Text Button` desktop application.
This opens a terminal running hotkeys.py which can help you monitor the logs, stdout, stderr.

requires: nix and home manager

Most linux desktop environments should have support for this. I've created an entry for this executable as
a desktop application.

To use in Nix system, you'd import ./speech-to-text-button (loading default.nix nix module)


## Hotkeys

After hotkeys.py is executed,

| Hotkey   | description                                                           |
|----------|-----------------------------------------------------------------------|
| ctrl + ] | load model and start dictation or pause dictation or resume dictation |
| ctrl + [ | end dictation deallocating memory taken by the model and libs         |

I'm open to suggestions for better default hotkeys.


## TODO

These are improvements I thought of. I'm not necessarily planning on doing these.

`speech-to-text-button/`
- [x] download and bundle a better model in the build of the store derivation
- [x] fix .desktop application - it's not linking to toggle-typing.sh correctly
- [x] absolute path for nerd-dictation and ./venv created by `nix-shell python.nix` and bundle nerd-dictation with nix module default.nix
- [x] python.nix (nix-shell) could build from my own derivation for nerd-dictation instead
- [ ] test this on a fresh install running x86 64 linux with X11 running NixOS
- [ ] add build attribute to let the user choose which model to download and use
- [ ] test and fix usage on headless linux (TTY)
- [ ] bundle my nix-build derivation to serve an executable for non-Nix systems
- [ ] avoid multiple processes running hotkeys.py - toggle-typing.sh should be multi-process safe as it should refer to the same screen session
- [ ] add build attributes to define custom hotkeys
- [ ] define word mapping for common words and phrases that aren't normally spoken (like "nix")
- [x] debug reason nerd-dictation dictating silence to "the" for me on silent idle -- (used an improved model for VOSK)
- [ ] better default hotkeys

`nerd-dictation/`
- [ ] define nix runCommand or wrap nerd-dictation defining `--vosk-model-dir=some/nix/path/model` appending args added by the user for use with nerd-dictation or patch it in a more hacky way?
- [ ] add home-manager as a dep in the build or add a systemd service to create ~/.config/nerd-dictation/model, download, unzip model before runtime for runtime?


## Alternatives

These options can only be used in certain contexts or applications.

### Web API

This uses a remote relay server to process audio for speech to text. If you run chromium or chrome, you can use
my prototype https://tarasoft.pro/speech-to-text.html

It's about <100 lines of HTML and JS.

You permit audio permission request via your browser for the web page/site, speak, copy and paste your text.

### Android Gboard

Press the mic button. Probably uses a remote relay server to process your audio.


## `nerd-dictation/`

This is an experimental nix derivation creation for: libvosk, vosk, nerd-dictation


## Sources

This software is directly built on top of other software including:
- [nerd-dictation](https://github.com/ideasman42/nerd-dictation)
- [vosk-api (C lib and python module)](https://github.com/alphacep/vosk-api)
- [vosk models](https://alphacephei.com/vosk/models)
