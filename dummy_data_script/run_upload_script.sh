#!/bin/bash

# Script to run the Firebase product upload script
echo "Starting Firebase product upload script..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed or not in PATH"
    echo "Please install Node.js from https://nodejs.org/"
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "npm is not installed or not in PATH"
    echo "Please install npm (usually comes with Node.js)"
    exit 1
fi

# Check if the .env file exists in parent directory
if [ ! -f "../.env" ]; then
    echo "Error: .env file not found in parent directory. Please make sure you have your Firebase configuration in .env file"
    exit 1
fi

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

# Run the Node.js script
echo "Running upload script..."
node upload_products.js

echo "Upload script completed!"