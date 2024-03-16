@echo off

set "ini_file=config.ini"

:: Install pyenv
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -Verb RunAs powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass Invoke-WebRequest -UseBasicParsing -Uri \"https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1\" -OutFile ./install-pyenv-win.ps1 ; & ./install-pyenv-win.ps1'"

:: Verify pyenv
for /f "delims=pyenv " %%V in ('pyenv --version') do @set pyenv_ver=%%V
echo pyenv with version %pyenv_ver% installed.

:: Parse
set "py_ver="
set "requirements_dir="

for /f "tokens=1,2 delims==" %%a in ('type "%ini_file%" ^| findstr /i "="') do (
    if /i "%%a"=="PYTHON_VERSION" (
        set "py_ver=%%b"
    ) else if /i "%%a"=="REQUIREMENTS_DIR" (
        set "requirements_dir=%%b"
    )
)

:: Search for latest minor release
for /f "delims=" %%i in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "$latestVersion = (pyenv install --list | Where-Object {$_ -like '%py_ver%.*'} | ForEach-Object { $_ -replace '^.*?(\d+\.\d+\.\d+).*$', '$1' } | Sort-Object -Descending | Select-Object -First 1); Write-Output $latestVersion"') do (
    set "py_ver=%%i"
)

:: Install
echo installing python version %py_ver%
powershell -NoProfile -ExecutionPolicy Bypass -Command "pyenv install %py_ver%"

:: Set global
echo setting python %py_ver% as global
powershell -NoProfile -ExecutionPolicy Bypass -Command "pyenv global %py_ver%"

:: Get Current Version
for /f "delims=" %%i in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "(python --version) 2>&1"') do (
    for /f "tokens=2 delims= " %%j in ("%%i") do set "curr_py_ver=%%j"
)

:: Verify Version
echo current python version: %curr_py_ver%
if "%py_ver%"=="%curr_py_ver%" (
    echo python installation successfully verified: %curr_py_ver%
) else (
    echo failed to verify python version. expected: %py_ver%, actual: %curr_py_ver%
    pause
    exit /b
)

:: Prepare Venv
:: Note: python -m venv venv will cause proc exit, so we do wrap with powershell call
echo generating venv...
powershell -NoProfile -ExecutionPolicy Bypass -Command "python -m venv venv"
echo activating venv...
call .\venv\Scripts\activate.bat

:: Install Dependencies
echo installing dependencies using pip...
powershell -NoProfile -ExecutionPolicy Bypass -Command "python -m pip install --upgrade -r %requirements_dir%"

:: You may ignore these three lines if you don't want the streamdiffusion
python -m pip install --upgrade torch==2.1.0 torchvision==0.16.0 xformers --index-url https://download.pytorch.org/whl/cu121
python -m pip install git+https://github.com/cumulo-autumn/StreamDiffusion.git@main#egg=streamdiffusion[tensorrt]
python -m streamdiffusion.tools.install-tensorrt

echo installing stubs...
xcopy /E /I /Y "_stubs" "venv\Lib\site-packages\_stubs"

if %errorlevel% neq 0 (
    echo installation failed. please check your configurations and try again.
) else (
    echo installation successful.
)