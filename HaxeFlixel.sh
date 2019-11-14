#! /bin/bash

# First we need to install Haxe.
# https://haxe.org/download/linux/
sudo pacman -Syu haxe

# Setup the Haxelib repository.
mkdir ~/haxelib
haxelib setup ~/haxelib

# Install and setup Flixel tools.
# https://haxeflixel.com/documentation/install-haxeflixel/
haxelib install lime
haxelib install openfl
haxelib install flixel
haxelib run lime setup flixel
haxelib run lime setup
haxelib install flixel-tools
haxelib run flixel-tools setup
