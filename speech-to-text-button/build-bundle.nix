{ stdenv }:
stdenv.mkDerivation rec {
  pname = "speech-to-text-button-bundle";

  version = "1.0";

  src = ./.;

  installPhase = ''
    mkdir -p $out/bin

    cp hotkeys.py $out/bin/hotkeys.py
    chmod +x $out/bin/hotkeys.py

    cp toggle-typing.sh $out/bin/toggle-typing.sh
    chmod +x $out/bin/toggle-typing.sh

    cp nerd-dictation $out/bin/nerd-dictation
    chmod +x $out/bin/nerd-dictation

    cp python.nix $out/bin/python.nix
  '';

  meta = with stdenv.lib; {
    description = "Press a button, computer types what you speak";
    maintainers = [ "jtara1" ];
#    maintainers = with maintainers; [ jtara1 ];
  };
}
