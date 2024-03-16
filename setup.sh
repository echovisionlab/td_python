#!/bin/sh

ini_file="config.ini"

# Check if config.ini exists
if [ ! -f "$ini_file" ]; then
    echo "Error: config.ini not found."
    exit 1
fi

# Parse config.ini
REQUIREMENTS_DIR=$(awk -F '=' '/REQUIREMENTS_DIR/ {print $2}' "$ini_file" | tr -d '[:space:]')
PYTHON_VERSION=$(awk -F '=' '/PYTHON_VERSION/ {print $2}' "$ini_file" | tr -d '[:space:]')

# Check if requirements directory is specified
if [ -z "$REQUIREMENTS_DIR" ]; then
    echo "Error: REQUIREMENTS_DIR is not specified in config.ini."
    exit 1
fi

# Check if python version is specified
if [ -z "$PYTHON_VERSION" ]; then
    echo "Error: PYTHON_VERSION is not specified in config.ini."
    exit 1
fi

# Install pyenv if not installed
if ! command -v pyenv > /dev/null; then
    echo "Installing pyenv..."
    curl https://pyenv.run | bash
fi

# Activate pyenv
eval "$(pyenv init -)"

# Find latest minor release of specified Python version
LATEST_VERSION=$(pyenv install --list | grep -E "^ *$PYTHON_VERSION\.[0-9]+$" | tail -n 1 | sed 's/^[[:space:]]*//')

# Check if latest version is empty
if [ -z "$LATEST_VERSION" ]; then
    echo "Error: Failed to find the latest version of Python $PYTHON_VERSION."
    exit 1
fi

# Install latest Python version
echo "Installing Python version $LATEST_VERSION..."
if ! pyenv install "$LATEST_VERSION" -s; then
    echo "Error: Failed to install Python version $LATEST_VERSION."
    exit 1
fi

# Set global Python version
pyenv global "$LATEST_VERSION"

# Activate virtual environment
if [ ! -d "venv" ]; then
    echo "Generating venv..."
    python -m venv venv
fi

echo "Activating venv..."
. venv/bin/activate

# Install dependencies
echo "Installing dependencies from $REQUIREMENTS_DIR using pip..."
if ! python -m pip install --upgrade -r "$REQUIREMENTS_DIR"; then
    echo "Error: Failed to install dependencies."
    exit 1
fi

STUBS_DIR="venv/lib/python$PYTHON_VERSION/site-packages/_stubs"
mkdir -p "$STUBS_DIR"

# Install stubs
echo "Installing stubs..."
if ! cp -r _stubs/* "$STUBS_DIR"; then
    echo "Error: Failed to install stubs."
    exit 1
fi

echo "Installation successful."