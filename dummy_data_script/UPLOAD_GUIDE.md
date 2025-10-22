# Product Data Upload Guide

This guide explains how to upload product data from JSON files to Firebase Firestore.

## Files Structure

The script will upload data from the following files:

### Products (to `products` collection):
- `cpu.json` - CPU products
- `drive.json` - Storage drives (HDD/SSD)
- `gpu.json` - Graphics cards
- `ram.json` - Memory modules
- `mainboard.json` - Motherboards
- `psu.json` - Power supplies

### Manufacturers (to `manufacturers` collection):
- `manufacturer.json` - Manufacturer information

## Prerequisites

1. **Node.js** (version 16 or higher)
2. **Firebase project** with Firestore enabled
3. **Firebase service account key**

## Setup

### 1. Install Dependencies

```bash
cd dummy_data_script
npm install
```

### 2. Firebase Configuration

You need to set up Firebase credentials in your `.env` file in the project root:

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your-service-account@project.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_CLIENT_ID=your-client-id
```

#### Getting Firebase Credentials:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** > **Service Accounts**
4. Click **"Generate new private key"**
5. Download the JSON file
6. Extract the values and add them to your `.env` file

### 3. Validate Data (Optional)

Before uploading, you can validate the JSON files:

```bash
npm run validate
```

This will check all files and show you how many products/manufacturers will be uploaded.

## Upload Commands

### Upload Everything (Recommended)

```bash
npm run upload-all
```

This will:
1. Upload manufacturers to `manufacturers` collection
2. Delete all existing products
3. Upload all products from the specified JSON files to `products` collection

### Upload Products Only

```bash
npm run upload
```

This uploads only products (uses the existing `upload_products.js` script).

## What the Script Does

1. **Manufacturers Upload**:
   - Deletes existing manufacturers
   - Uploads all manufacturers from `manufacturer.json`

2. **Products Upload**:
   - Deletes all existing products
   - Uploads products from specific files:
     - `cpu.json`
     - `drive.json`
     - `gpu.json`
     - `ram.json`
     - `mainboard.json`
     - `psu.json`

3. **Batch Processing**:
   - Uploads data in batches of 500 documents to avoid Firebase limits
   - Continues processing even if individual batches fail

## Data Structure

### Product Structure
Each product contains:
- `productName`: Product name
- `category`: Product category (cpu, drive, gpu, ram, mainboard, psu)
- `manufacturer`: Manufacturer name
- `attributes`: Category-specific attributes
- `productID`: Unique product identifier
- `importPrice`: Import price
- `sellingPrice`: Selling price
- `sales`: Number of sales
- `stock`: Stock quantity
- `discount`: Discount percentage
- `warranty`: Warranty information
- `enDescription`: English description
- `viDescription`: Vietnamese description
- `imageUrl`: Product image URL
- `release`: Release timestamp

### Manufacturer Structure
Each manufacturer contains:
- `manufacturerID`: Unique manufacturer identifier
- `manufacturerName`: Manufacturer name
- `status`: Active status

## Troubleshooting

### Common Issues

1. **Firebase Authentication Error**:
   - Check your `.env` file has correct credentials
   - Ensure the service account has Firestore permissions

2. **File Not Found**:
   - Ensure JSON files exist in `../lib/data/new_data/`
   - Check file names match exactly

3. **Upload Fails**:
   - Check Firebase project has Firestore enabled
   - Verify service account has write permissions
   - Check internet connection

### Logs

The script provides detailed logging:
- Shows progress for each file
- Reports batch upload progress
- Shows total counts uploaded
- Reports any errors encountered

## Safety Features

- **Backup**: The script deletes existing data, so backup your Firestore before running
- **Batch Processing**: Uses batches to avoid Firebase limits
- **Error Handling**: Continues processing even if individual batches fail
- **Validation**: Optional validation step to check data before upload

## File Locations

```
dummy_data_script/
├── upload_products_and_manufacturers.js  # Main upload script
├── validate_data.js                      # Data validation script
├── package.json                          # Dependencies and scripts
└── UPLOAD_GUIDE.md                       # This guide

../lib/data/new_data/
├── cpu.json
├── drive.json
├── gpu.json
├── ram.json
├── mainboard.json
├── psu.json
└── manufacturer.json
```
