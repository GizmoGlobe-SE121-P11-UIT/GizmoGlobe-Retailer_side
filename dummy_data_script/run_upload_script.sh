#!/bin/bash

# Script to run the Firebase product upload script
echo "Starting Firebase product upload script..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed or not in PATH"
    echo "Please install Node.js from https://nodejs.org/"
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "Error: npm is not installed or not in PATH"
    echo "Please install npm (usually comes with Node.js)"
    exit 1
fi

# Check Node.js version (should be >= 16.0.0 as per package.json)
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 16 ]; then
    echo "Error: Node.js version 16.0.0 or higher is required. Current version: $(node -v)"
    exit 1
fi

# Check if the .env file exists in the project root directory
if [ ! -f "../.env" ]; then
    echo "Error: .env file not found in the project root directory."
    echo "Please make sure you have your Firebase configuration in .env file"
    exit 1
fi

# Check if the upload script exists
if [ ! -f "upload_products.js" ]; then
    echo "Error: upload_products.js not found in the current directory"
    exit 1
fi

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    if ! npm install; then
        echo "Error: Failed to install dependencies"
        exit 1
    fi
fi

# Run the Node.js script
echo "Running upload script..."
if ! node upload_products.js; then
    echo "Error: Upload script failed"
    exit 1
fi

echo "Upload script completed successfully!"