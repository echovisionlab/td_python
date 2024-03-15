import os
import pathlib
import stat
import subprocess
import sys

win_txt = ''':: update pip
python -m pip install --user --upgrade pip

:: install from requirements file
{exec} -m pip install -r "{reqs}" --target="{target}"
'''

mac_txt = '''#!/bin/sh
dep=$(dirname "$0")
pythonDir=/python

# change current directory to where the script is run from
dirname="$(readlink -f "$0")"

# fix up pip with python3
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
{exec} get-pip.py

# update dependencies
{exec} -m pip install --user --upgrade pip

{exec} -m pip install -r "{reqs}" --target="{target}"
'''

version = sys.version.split(" ")[0]
req_file = tdu.expand(ipar.ExtPython.Pyreqs)
install_target = tdu.expandPath(ipar.ExtPython.Installtarget)
install_script_path = pathlib.Path(install_target).parents[0]


def write_file(path, content):
    print("writing file:", path)
    with open(path, "w+") as f:
        f.write(content)


def set_runnable(path):
    print("setting script mode to runnable:", path)
    mode = os.stat(path).st_mode
    mode |= (mode & 0o444) >> 2
    os.chmod(path, mode)


def run_file(path):
    print("running file:", path)
    subprocess.call(path)


def install_deps_win():
    installer_dir = str(install_script_path / 'dep_install.cmd')
    fmt_win = win_txt.format(exec=sys.executable, reqs=req_file, target=install_target)
    write_file(installer_dir, fmt_win)



def install_deps_mac():
    installer_dir = str(install_script_path / 'dep_install.sh')
    fmt_mac = mac_txt.format(exec=sys.executable, reqs=req_file, target=install_target)
    write_file(installer_dir, fmt_mac)
    set_runnable(installer_dir)


print("prepare dependencies...")
if sys.platform == "darwin":
    install_deps_mac()
elif sys.platform == "win32":
    install_deps_win()
