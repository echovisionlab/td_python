# td_python

A simpleton project to be reused over time.

The base_qrcode section does reflect the text DATs lying under the qrcode base, in order to naturally incorporate
the structures from the TD project. It is not necessary for you to keep things in this manner, however,
it is simply an example of how I keep things under the hood.

This project is inspired from the following [guide](https://derivative.ca/community-post/tutorial/external-python-libraries/61022).

### Preparation
If you have specific dependencies, the given requirements.txt must be populated before you run the scripts.

Also, if you have switched from one system to another, you must not keep the venv.
Just keep the requirements.txt as a single source of truth, as well as the version of the python to be used with.


### Windows
The provided setup.bat will automatically install the python version that matches the version from the config.ini.
It will install the required dependencies to the venv and adds stubs to the site-packages directory.

### macOS
The provided setup.sh to run the installation.
In order to run the setup.sh, run following commands from the terminal.

```
# from the root directory of cloned directory (td_python)
chmod +x setup.sh && ./setup.sh
```

### Stubs
For stubs, please refer [this repo](https://github.com/optexture/td-components).
This is immensely helpful for us to develop the scripts that needs to use TD specific objects and references,
that's why we use it!