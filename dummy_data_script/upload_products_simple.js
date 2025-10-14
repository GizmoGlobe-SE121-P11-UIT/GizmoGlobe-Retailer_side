const fs = require('fs');
const path = require('path');

// Load environment variables from .env file
require('dotenv').config({ path: path.join('..', '.env') });

async function main() {
  try {
    // Get project ID from existing environment variables
    const projectId = process.env.FIREBASE_ANDROID_PROJECT_ID || process.env.FIREBASE_WEB_PROJECT_ID;
    
    if (!projectId) {
      throw new Error('Firebase project ID not found in environment variables. Please set FIREBASE_ANDROID_PROJECT_ID or FIREBASE_WEB_PROJECT_ID');
    }

    console.log(`Using Firebase project: ${projectId}`);

    // For now, let's just validate the JSON files and show what would be uploaded
    console.log('Validating JSON files...');
    await validateJsonFiles();

    console.log('\n⚠️  IMPORTANT: This script is ready to upload data, but you need Firebase Admin SDK credentials.');
    console.log('To get the service account key:');
    console.log('1. Go to Firebase Console > Project Settings > Service Accounts');
    console.log('2. Click "Generate new private key"');
    console.log('3. Download the JSON file');
    console.log('4. Add these to your .env file:');
    console.log('   FIREBASE_PROJECT_ID=' + projectId);
    console.log('   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\\n...\\n-----END PRIVATE KEY-----\\n"');
    console.log('   FIREBASE_CLIENT_EMAIL=your-service-account@project.iam.gserviceaccount.com');
    console.log('   FIREBASE_PRIVATE_KEY_ID=your-private-key-id');
    console.log('   FIREBASE_CLIENT_ID=your-client-id');
    console.log('\nThen run: node upload_products.js');

    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

async function validateJsonFiles() {
  const dataDir = path.join('..', 'lib', 'data', 'new_data');

  if (!fs.existsSync(dataDir)) {
    throw new Error(`Data directory does not exist: ${dataDir}`);
  }

  const files = fs.readdirSync(dataDir)
    .filter(file => file.endsWith('.json'))
    .map(file => path.join(dataDir, file));

  if (files.length === 0) {
    throw new Error(`No JSON files found in ${dataDir}`);
  }

  let totalProducts = 0;

  for (const file of files) {
    try {
      const fileContent = fs.readFileSync(file, 'utf8');

      if (fileContent.trim() === '') {
        console.log(`⚠️  File is empty: ${path.basename(file)}`);
        continue;
      }

      const jsonData = JSON.parse(fileContent);

      if (!Array.isArray(jsonData)) {
        console.log(`⚠️  File ${path.basename(file)} does not contain an array`);
        continue;
      }

      if (jsonData.length === 0) {
        console.log(`⚠️  No data found in ${path.basename(file)}`);
        continue;
      }

      totalProducts += jsonData.length;
      console.log(`✅ ${path.basename(file)}: ${jsonData.length} products`);

      // Show sample of first product
      if (jsonData.length > 0) {
        console.log(`   Sample product: ${JSON.stringify(jsonData[0], null, 2).substring(0, 200)}...`);
      }

    } catch (error) {
      console.log(`❌ Error reading ${path.basename(file)}: ${error.message}`);
    }
  }

  console.log(`\n📊 Total products to upload: ${totalProducts}`);
}

// Run the script
main();
