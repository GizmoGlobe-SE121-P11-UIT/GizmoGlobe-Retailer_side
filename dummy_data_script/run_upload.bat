@echo off
echo Starting Firebase product upload script...

REM Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

REM Check if npm is installed
where npm >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo npm is not installed or not in PATH
    echo Please install npm (usually comes with Node.js)
    pause
    exit /b 1
)

REM Check if the .env file exists in parent directory
if not exist "..\.env" (
    echo Error: .env file not found in parent directory. Please make sure you have your Firebase configuration in .env file
    pause
    exit /b 1
)

REM Install dependencies if node_modules doesn't exist
if not exist "node_modules" (
    echo Installing dependencies...
    npm install
)

REM Run the Node.js script
echo Running upload script...
node upload_products.js

echo Upload script completed!
pause
