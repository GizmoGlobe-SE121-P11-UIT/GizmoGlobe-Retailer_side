# Quick Usage Guide

## 🚀 How to Upload Products

### From the `dummy_data_script` directory:

```bash
# Navigate to the script directory
cd dummy_data_script

# Run the upload script
./run_upload_script.sh    # Mac/Linux
# OR
run_upload.bat            # Windows
```

### What it does:
1. ✅ Deletes all existing products from Firebase
2. ✅ Uploads 300 products from JSON files
3. ✅ Raw data upload (no transformation)

### Files processed:
- **CPU**: 50 products
- **Drive**: 79 products  
- **GPU**: 51 products
- **Mainboard**: 20 products
- **PSU**: 50 products
- **RAM**: 50 products

## 📁 Directory Structure

```
dummy_data_script/
├── upload_products.js          # Main upload script
├── upload_products_simple.js   # Validation script
├── run_upload_script.sh        # Unix/Mac runner
├── run_upload.bat             # Windows runner
├── package.json               # Dependencies
├── README.md                  # Full documentation
└── USAGE.md                   # This file

../                             # Parent directory
├── .env                       # Firebase config
└── lib/data/new_data/         # JSON data files
```

## ⚠️ Important Notes

- **Backup your data**: Script deletes all existing products
- **Raw upload**: No data transformation or mapping
- **App compatibility**: Your app will need refactoring to work with new data
- **Firebase credentials**: Must be configured in `../.env`

## 🔧 Troubleshooting

- **"No .env found"**: Make sure `../.env` exists with Firebase credentials
- **"No JSON files"**: Check `../lib/data/new_data/` has JSON files
- **"Node.js not found"**: Install Node.js from https://nodejs.org/
