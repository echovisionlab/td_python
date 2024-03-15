import os
import sys

if getattr(sys, 'frozen', False):
    application_path = os.path.dirname(sys.executable)
elif __file__:
    application_path = os.path.dirname(__file__)

spacer = "- " * 5

for each in sys.path:
    print(each)

print(spacer)

python_extPython = tdu.expandPath(ipar.ExtPython.Installtarget)

if python_extPython not in sys.path:
    sys.path.append(python_extPython)
