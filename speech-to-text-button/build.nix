# build: $ nix-build -o result --verbose build.nix
# run: $ ./result/bin/hotkeys.py
{
  pkgs
  , nerd-dictation
}:
with (pkgs) stdenv;
stdenv.mkDerivation rec {
  pname = "speech-to-text-button";

  version = "1.0";

  src = ./.;

  propogatedBuildInputs = [
    nerd-dictation
    pkgs.screen
  ];

  installPhase = ''
    mkdir -p $out/bin

    cp hotkeys.py $out/bin/hotkeys.py
    chmod +x $out/bin/hotkeys.py

    cp toggle-typing.sh $out/bin/toggle-typing.sh
    chmod +x $out/bin/toggle-typing.sh
  '';

  meta = with stdenv.lib; {
    description = "Press a button, computer types what you speak";
    maintainers = [ "jtara1" ];
    license = pkgs.lib.licenses.asl20;
  };
}
