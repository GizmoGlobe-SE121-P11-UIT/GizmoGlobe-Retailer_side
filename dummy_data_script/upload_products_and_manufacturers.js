const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Load environment variables from .env file
require('dotenv').config({ path: path.join('..', '.env') });

async function main() {
  try {
    // Initialize Firebase Admin SDK using service account credentials
    const serviceAccount = {
      type: "service_account",
      project_id: process.env.FIREBASE_PROJECT_ID,
      private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
      private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
      client_email: process.env.FIREBASE_CLIENT_EMAIL,
      client_id: process.env.FIREBASE_CLIENT_ID,
      auth_uri: "https://accounts.google.com/o/oauth2/auth",
      token_uri: "https://oauth2.googleapis.com/token",
      auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
      client_x509_cert_url: `https://www.googleapis.com/robot/v1/metadata/x509/${encodeURIComponent(process.env.FIREBASE_CLIENT_EMAIL)}`
    };

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });

    console.log('Firebase initialized successfully');

    const db = admin.firestore();

    // Upload manufacturers first
    console.log('Uploading manufacturers...');
    await uploadManufacturers(db);
    console.log('Manufacturers uploaded successfully');

    // Delete all existing products
    console.log('Deleting all existing products...');
    await deleteAllProducts(db);
    console.log('All existing products deleted successfully');

    // Upload products from specific JSON files
    console.log('Uploading products...');
    await uploadProductsFromSpecificFiles(db);
    console.log('All products uploaded successfully');

    console.log('Script completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

async function uploadManufacturers(db) {
  try {
    const manufacturerFile = path.join('..', 'lib', 'data', 'new_data', 'manufacturer.json');
    
    if (!fs.existsSync(manufacturerFile)) {
      console.log('Manufacturer file not found, skipping...');
      return;
    }

    const fileContent = fs.readFileSync(manufacturerFile, 'utf8');
    const manufacturers = JSON.parse(fileContent);

    if (!Array.isArray(manufacturers) || manufacturers.length === 0) {
      console.log('No manufacturer data found');
      return;
    }

    // Delete existing manufacturers
    console.log('Deleting existing manufacturers...');
    const existingManufacturers = await db.collection('manufacturers').get();
    if (!existingManufacturers.empty) {
      const batch = db.batch();
      existingManufacturers.docs.forEach(doc => {
        batch.delete(doc.ref);
      });
      await batch.commit();
      console.log(`Deleted ${existingManufacturers.docs.length} existing manufacturers`);
    }

    // Upload manufacturers in batches
    const batchSize = 500;
    let uploaded = 0;

    for (let i = 0; i < manufacturers.length; i += batchSize) {
      const batchEnd = Math.min(i + batchSize, manufacturers.length);
      const batch = manufacturers.slice(i, batchEnd);

      try {
        await uploadManufacturerBatch(db, batch);
        uploaded += batch.length;
        console.log(`Uploaded manufacturer batch ${Math.floor(i / batchSize) + 1}: ${batch.length} manufacturers`);
      } catch (error) {
        console.error(`Error uploading manufacturer batch ${Math.floor(i / batchSize) + 1}:`, error);
      }
    }

    console.log(`Total manufacturers uploaded: ${uploaded}`);
  } catch (error) {
    console.error('Error uploading manufacturers:', error);
    throw error;
  }
}

async function uploadManufacturerBatch(db, manufacturers) {
  try {
    const batch = db.batch();

    manufacturers.forEach(manufacturerData => {
      if (typeof manufacturerData !== 'object' || manufacturerData === null) {
        console.log('Skipping invalid manufacturer data:', manufacturerData);
        return;
      }

      // Create a new document reference
      const docRef = db.collection('manufacturers').doc();
      batch.set(docRef, manufacturerData);
    });

    await batch.commit();
  } catch (error) {
    console.error('Error uploading manufacturer batch:', error);
    throw error;
  }
}

async function deleteAllProducts(db) {
  try {
    const snapshot = await db.collection('products').get();
    
    if (snapshot.empty) {
      console.log('No products found to delete');
      return;
    }

    // Delete documents in batches to avoid Firebase limits
    const batchSize = 500;
    const batches = [];
    let currentBatch = db.batch();
    let currentBatchSize = 0;

    snapshot.docs.forEach(doc => {
      currentBatch.delete(doc.ref);
      currentBatchSize++;

      if (currentBatchSize >= batchSize) {
        batches.push(currentBatch);
        currentBatch = db.batch();
        currentBatchSize = 0;
      }
    });

    // Add the last batch if it has any operations
    if (currentBatchSize > 0) {
      batches.push(currentBatch);
    }

    // Execute all batches
    for (const batch of batches) {
      await batch.commit();
    }

    console.log(`Deleted ${snapshot.docs.length} products`);
  } catch (error) {
    console.error('Error deleting products:', error);
    throw error;
  }
}

async function uploadProductsFromSpecificFiles(db) {
  const dataDir = path.join('..', 'lib', 'data', 'new_data');
  
  // Specific files to upload
  const productFiles = [
    'cpu.json',
    'drive.json', 
    'gpu.json',
    'ram.json',
    'mainboard.json',
    'psu.json'
  ];

  let totalUploaded = 0;

  for (const fileName of productFiles) {
    const filePath = path.join(dataDir, fileName);
    
    if (!fs.existsSync(filePath)) {
      console.log(`File not found: ${fileName}, skipping...`);
      continue;
    }

    console.log(`Processing file: ${fileName}`);
    const uploaded = await uploadProductsFromFile(db, filePath);
    totalUploaded += uploaded;
    console.log(`Uploaded ${uploaded} products from ${fileName}`);
  }

  console.log(`Total products uploaded: ${totalUploaded}`);
}

async function uploadProductsFromFile(db, filePath) {
  try {
    const fileContent = fs.readFileSync(filePath, 'utf8');

    if (fileContent.trim() === '') {
      console.log(`File is empty: ${path.basename(filePath)}`);
      return 0;
    }

    const jsonData = JSON.parse(fileContent);

    if (!Array.isArray(jsonData) || jsonData.length === 0) {
      console.log(`No data found in ${path.basename(filePath)}`);
      return 0;
    }

    // Upload products in batches
    const batchSize = 500;
    let uploaded = 0;

    for (let i = 0; i < jsonData.length; i += batchSize) {
      const batchEnd = Math.min(i + batchSize, jsonData.length);
      const batch = jsonData.slice(i, batchEnd);

      try {
        await uploadProductBatch(db, batch);
        uploaded += batch.length;
        console.log(`Uploaded batch ${Math.floor(i / batchSize) + 1}: ${batch.length} products`);
      } catch (error) {
        console.error(`Error uploading batch ${Math.floor(i / batchSize) + 1}:`, error);
        // Continue with next batch instead of failing completely
      }
    }

    return uploaded;
  } catch (error) {
    console.error(`Error processing file ${filePath}:`, error);
    throw error;
  }
}

async function uploadProductBatch(db, products) {
  try {
    const batch = db.batch();

    products.forEach(productData => {
      // Skip if productData is not an object
      if (typeof productData !== 'object' || productData === null) {
        console.log('Skipping invalid product data:', productData);
        return;
      }

      // Create a new document reference
      const docRef = db.collection('products').doc();

      // Upload the raw JSON data directly without any transformation
      const firebaseData = { ...productData };

      // Add the document to the batch
      batch.set(docRef, firebaseData);
    });

    // Commit the batch
    await batch.commit();
  } catch (error) {
    console.error('Error uploading product batch:', error);
    throw error;
  }
}

// Run the script
main();
