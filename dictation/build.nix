# build: $ nix-build -o result --verbose build.nix
# run: $ ./result/bin/hotkeys.py
{
  pkgs ? import <nixpkgs> {}
  , nerd-dictation ? import ./nerd-dictation {}
}:
with pkgs;
stdenv.mkDerivation {
  pname = "dictation";
  version = "1.1";

  src = ./.;

  installPhase = ''
    mkdir -p $out/lib

    cp hotkeys.py $out/lib/
    chmod +x $out/lib/hotkeys.py

    cp toggle-typing.sh $out/lib/
    chmod +x $out/lib/toggle-typing.sh
  '';

  postInstall = ''
    wrapProgram $out/lib/hotkeys.py --prefix PATH : ${lib.makeBinPath [
      (pkgs.python3.withPackages (p: with p; [ p.pynput ]))
    ]}
    wrapProgram $out/lib/toggle-typing.sh --prefix PATH : ${lib.makeBinPath [ nerd-dictation pkgs.screen ]}
  '';

  meta = {
    description = "Press a button, computer types what you speak";
    maintainers = [ "jtara1" ];
    license = lib.licenses.asl20;
  };
}
