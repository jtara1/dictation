#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p "python3.withPackages (p: with p; [ p.pynput ])"

import subprocess
import os
from os.path import dirname, abspath, join
import threading
import argparse

from pynput import keyboard


def run_shell_script(subcmd=None):
	script_path = parse_cli_args().file_path
	cmd = [x for x in ['bash', script_path, subcmd] if x]
# 	print(f'executing: {" ".join(cmd)}')
	subprocess.Popen(cmd)


def parse_cli_args():
	parser = argparse.ArgumentParser(description='file path')
	parser.add_argument('file_path', type=str, nargs='?', help='The path to the file (optional)',
						default=join(dirname(__file__), 'toggle-typing.sh'))

	args = parser.parse_args()

	if args.file_path and not os.path.isfile(args.file_path):
		print(f"The file {args.file_path} does not exist.")

	return args


def main():
	try:
		# hotkey1
		toggle_dictation_hotkey = [
			keyboard.Key.ctrl,
			keyboard.Key.shift,
			keyboard.KeyCode.from_char(']')
		]

		toggle_hotkey = keyboard.HotKey(
			toggle_dictation_hotkey,
			run_shell_script)

		toggle_listener = keyboard.Listener(
			on_press=lambda key: toggle_hotkey.press(toggle_listener.canonical(key)),
			on_release=lambda key: toggle_hotkey.release(toggle_listener.canonical(key)))

		toggle_listener.start()

		# hotkey2
		end_dictation_hotkey = [
			keyboard.Key.ctrl,
			keyboard.Key.shift,
			keyboard.KeyCode.from_char('{')
		]

		ender_hotkey = keyboard.HotKey(
			end_dictation_hotkey,
			lambda: run_shell_script('end'))

		ender_listener = keyboard.Listener(
			on_press=lambda key: ender_hotkey.press(ender_listener.canonical(key)),
			on_release=lambda key: ender_hotkey.release(ender_listener.canonical(key)))

		ender_listener.start()

		print(
			f'listening for global hotkeys:\n\t{toggle_hotkey._keys}: resume or pause\n\t{ender_hotkey._keys}: end dictation')
		ender_listener.join()
	finally:
		try:
			toggle_listener.stop()
		except:
			pass

		try:
			ender_listener.stop()
		except:
			pass


if __name__ == '__main__':
	main()
