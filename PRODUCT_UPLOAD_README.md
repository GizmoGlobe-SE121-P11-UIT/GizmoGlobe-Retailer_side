# Firebase Product Upload Script

This script allows you to delete all existing products from your Firebase "products" collection and upload new product data from JSON files in the `lib/data/new_data/` directory. **The script uploads raw JSON data without any transformation or mapping.**

## Prerequisites

1. **Node.js** (version 16 or higher) installed and configured
2. **Firebase project** set up with Firestore
3. **Environment variables** configured in `.env` file
4. **JSON data files** in `lib/data/new_data/` directory

## Files

- `upload_products.js` - Main Node.js script that handles the upload process
- `package.json` - Node.js dependencies and scripts
- `run_upload_script.sh` - Shell script for Unix/Linux/Mac systems
- `run_upload_script.bat` - Batch script for Windows systems
- `lib/data/new_data/` - Directory containing JSON files with product data

## Usage

### Method 1: Using the provided scripts (Recommended)

#### For Unix/Linux/Mac:
```bash
./run_upload_script.sh
```

#### For Windows:
```cmd
run_upload_script.bat
```

### Method 2: Direct execution
```bash
# Install dependencies first (only needed once)
npm install

# Run the script
node upload_products.js
```

## What the script does

1. **Initializes Firebase** using your configuration
2. **Deletes all existing products** from the "products" collection
3. **Reads JSON files** from `lib/data/new_data/` directory
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

## Important Notes

⚠️ **This script uploads raw data without any processing:**
- Your app may not work immediately after upload
- You'll need to refactor your app to handle the new data structure
- All JSON data is preserved exactly as provided
- No compatibility with existing app structure

## Data Structure

The script uploads your JSON data exactly as-is:

- **No field mapping** - original field names preserved
- **No data transformation** - values remain unchanged
- **No default values added** - only your original data
- **Raw JSON structure** maintained in Firebase

## Error Handling

The script includes comprehensive error handling:
- Validates JSON file structure
- Handles missing or invalid data
- Processes files in batches to avoid Firebase limits
- Provides detailed logging of the upload process

## Safety Features

- **Batch processing**: Uploads in batches of 500 documents
- **Transaction safety**: Uses Firebase batch operations
- **Error recovery**: Continues processing even if individual items fail
- **Logging**: Detailed output of what's being processed

## Troubleshooting

### Common Issues:

1. **"Firebase not initialized"**
   - Check your `.env` file configuration
   - Ensure Firebase project is properly set up

2. **"No JSON files found"**
   - Verify files are in `lib/data/new_data/` directory
   - Check file extensions are `.json`

3. **"Permission denied"**
   - Ensure you have write access to Firebase
   - Check Firebase security rules

4. **"Script fails to run"**
   - Make sure Flutter SDK is installed
   - Run `flutter doctor` to check installation

## Important Warnings

⚠️ **WARNING**: This script will **DELETE ALL EXISTING PRODUCTS** from your Firebase "products" collection. Make sure you have a backup if needed.

⚠️ **APP COMPATIBILITY**: This script uploads raw JSON data without any transformation. Your existing app will likely not work with this new data structure until you refactor your code to handle the new format.

## Support

If you encounter issues:
1. Check the console output for detailed error messages
2. Verify your Firebase configuration
3. Ensure all JSON files have valid structure
4. Check Firebase console for any permission issues
