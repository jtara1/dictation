from setuptools import setup, find_packages

setup(
	name='dictation_hotkeys',
	version='1.0.0',
	packages=find_packages(),
	install_requires=[
		'pynput',
	],
# 	entry_points={
# 		'console_scripts': [
# 			'dictation_hotkeys = dictation_hotkeys.hotkeys:main',
# 		],
# 	},
	author='James T',
	author_email='github.jtara1@gmail.com',
	# description='',
	# long_description=open('README.md').read(),
)
