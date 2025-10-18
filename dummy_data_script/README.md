# Firebase Product Upload Script

This directory contains scripts to upload product data from JSON files to Firebase Firestore.

## Files

- `upload_products.js` - Main Node.js script that handles the upload process
- `upload_products_simple.js` - Validation script to check JSON files before upload
- `package.json` - Node.js dependencies and scripts
- `run_upload_script.sh` - Shell script for Unix/Linux/Mac systems
- `README.md` - This documentation file

## Prerequisites

1. **Node.js** (version 16 or higher) installed and configured
2. **Firebase project** set up with Firestore
3. **Environment variables** configured in `../.env` file (parent directory)
4. **JSON data files** in `../lib/data/new_data/` directory (parent directory)

## Usage

### Method 1: Using the shell script (Recommended)

#### For Unix/Linux/Mac:
```bash
./run_upload_script.sh
```

### Method 2: Direct execution
```bash
# Install dependencies first (only needed once)
npm install

# Run the script
node upload_products.js

# Or validate files first
node upload_products_simple.js
```

## What the script does

1. **Initializes Firebase** using your configuration from `../.env`
2. **Deletes all existing products** from the "products" collection
3. **Reads JSON files** from `../lib/data/new_data/` directory
4. **Uploads raw JSON data** directly to Firebase without any transformation
5. **Preserves original data structure** - no mapping or modification

## JSON File Structure

The script expects JSON files with the following structure:

```json
[
  {
    "product_name": "CPU Intel Core Ultra 9 285K",
    "vendor": "Intel",
    "product_type": "cpu",
    "price": "17490000",
    "warranty": "",
    "attributes": {
      "series": "corei9Ultra9",
      "socket": "LGA 1851",
      "core": 24,
      "thread": 24,
      "base_clock": 3.7,
      "tdp": 250,
      "turbo_clock": 5.7
    }
  }
]
```

## Data Structure

The script uploads your JSON data exactly as-is:

- **No field mapping** - original field names preserved
- **No data transformation** - values remain unchanged
- **No default values added** - only your original data
- **Raw JSON structure** maintained in Firebase

## Important Notes

⚠️ **This script uploads raw data without any processing:**
- Your app may not work immediately after upload
- You'll need to refactor your app to handle the new data structure
- All JSON data is preserved exactly as provided
- No compatibility with existing app structure

## Error Handling

The script includes comprehensive error handling:
- Validates JSON file structure
- Handles batch upload failures gracefully
- Provides detailed error messages
- Continues processing even if individual batches fail
- Uses Node.js for better compatibility and fewer dependency issues

## Troubleshooting

1. **"No JSON files found"**
   - Make sure your JSON files are in `../lib/data/new_data/` directory
   - Check that files have `.json` extension

2. **"Firebase initialization failed"**
   - Verify your `../.env` file has correct Firebase configuration
   - Check that your Firebase project is properly set up
   - Make sure your service account key is properly formatted

3. **"Permission denied"**
   - Make sure your Firebase service account has Firestore write permissions
   - Verify your Firebase project ID is correct

4. **"Script fails to run"**
   - Make sure Node.js is installed (version 16 or higher)
   - Run `node --version` to check installation
   - Run `npm install` to install dependencies

## Important Warnings

⚠️ **WARNING**: This script will **DELETE ALL EXISTING PRODUCTS** from your Firebase "products" collection. Make sure you have a backup if needed.

⚠️ **APP COMPATIBILITY**: This script uploads raw JSON data without any transformation. Your existing app will likely not work with this new data structure until you refactor your code to handle the new format.

## Support

If you encounter issues:
1. Check the console output for detailed error messages
2. Verify your Firebase configuration
3. Ensure all required dependencies are installed
4. Check that JSON files are properly formatted

## Directory Structure

```
dummy_data_script/
├── upload_products.js          # Main upload script
├── upload_products_simple.js   # Validation script
├── run_upload_script.sh        # Shell script runner
├── package.json               # Node.js dependencies
├── package-lock.json          # Dependency lock file
└── README.md                  # This file

../                             # Parent directory
├── .env                       # Firebase configuration
└── lib/data/new_data/         # JSON data files
    ├── cpu.json
    ├── gpu.json
    ├── ram.json
    ├── mainboard.json
    ├── psu.json
    └── drive.json
```
