#!/bin/sh

ini_file="config.ini"

# Install pyenv
curl https://pyenv.run | bash

# Verify pyenv
pyenv_ver=$(pyenv --version)
echo "pyenv with version $pyenv_ver installed."

# Parse
py_ver=""
requirements_dir=""
dependencies_dir=""

while IFS='=' read -r key value; do
    case "$key" in
        "PYTHON_VERSION")
            py_ver="$value"
            ;;
        "REQUIREMENTS_DIR")
            requirements_dir="$value"
            ;;
        *)
            ;;
    esac
done < "$ini_file"

# Search for latest minor release
latest_version=$(pyenv install --list | grep -oE "$py_ver\.[0-9]+\.[0-9]+" | sort -r | head -n 1)

# Install
echo "installing python version $latest_version"
if ! pyenv install "$latest_version"; then
    echo "Failed to install python version $latest_version"
    exit 1
fi

# Set global
echo "setting python $latest_version as global"
if ! pyenv global "$latest_version"; then
    echo "Failed to set python version $latest_version as global"
    exit 1
fi

# Get Current Version
curr_py_ver=$(python --version 2>&1 | awk '{print $2}')

# Verify Version
echo "current python version: $curr_py_ver"
if [ "$py_ver" != "$curr_py_ver" ]; then
    echo "failed to verify python version. expected: $py_ver, actual: $curr_py_ver"
    exit 1
fi

# Prepare Venv
echo "generating venv..."
python -m venv venv
echo "activating venv..."
source ./venv/bin/activate

# Install Dependencies
echo "installing dependencies to $dependencies_dir using pip..."
if ! python -m pip install --upgrade -r "$requirements_dir"; then
    echo "Failed to install dependencies"
    exit 1
fi
if ! python -m pip install --upgrade torch==2.1.0 torchvision==0.16.0 xformers --index-url https://download.pytorch.org/whl/cu121; then
    echo "Failed to install additional dependencies"
    exit 1
fi
if ! python -m pip install git+https://github.com/cumulo-autumn/StreamDiffusion.git@main#egg=streamdiffusion[tensorrt]; then
    echo "Failed to install StreamDiffusion"
    exit 1
fi
if ! python -m streamdiffusion.tools.install-tensorrt; then
    echo "Failed to install StreamDiffusion TensorRT"
    exit 1
fi

# Install Stubs
echo "installing stubs..."
if ! cp -r _stubs/* "venv/lib/python3.9/site-packages/_stubs"; then
    echo "Failed to install stubs"
    exit 1
fi

echo "installation successful."