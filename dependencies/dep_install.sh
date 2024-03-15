#!/bin/sh
dep=$(dirname "$0")
pythonDir=/python

# change current directory to where the script is run from
dirname="$(readlink -f "$0")"

# fix up pip with python3
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
/Applications/TouchDesigner.app/Contents/MacOS/TouchDesigner get-pip.py

# update dependencies
/Applications/TouchDesigner.app/Contents/MacOS/TouchDesigner -m pip install --user --upgrade pip

/Applications/TouchDesigner.app/Contents/MacOS/TouchDesigner -m pip install -r "['base_qrcode/requirements.txt']" --target="/Volumes/Dev/td_python/dependencies/python"
