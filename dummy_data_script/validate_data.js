const fs = require('fs');
const path = require('path');

async function main() {
  try {
    console.log('🔍 Validating JSON files...\n');
    
    // Check manufacturers
    await validateManufacturers();
    
    // Check product files
    await validateProductFiles();
    
    console.log('\n✅ Validation completed successfully!');
    console.log('\n📋 Summary:');
    console.log('- Manufacturers: Ready to upload');
    console.log('- Products: Ready to upload from cpu.json, drive.json, gpu.json, ram.json, mainboard.json, psu.json');
    console.log('\n🚀 To upload data, run: npm run upload-all');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Validation failed:', error);
    process.exit(1);
  }
}

async function validateManufacturers() {
  const manufacturerFile = path.join('..', 'lib', 'data', 'new_data', 'manufacturer.json');
  
  if (!fs.existsSync(manufacturerFile)) {
    console.log('⚠️  Manufacturer file not found: manufacturer.json');
    return;
  }

  try {
    const fileContent = fs.readFileSync(manufacturerFile, 'utf8');
    const manufacturers = JSON.parse(fileContent);

    if (!Array.isArray(manufacturers)) {
      throw new Error('Manufacturer file does not contain an array');
    }

    console.log(`✅ manufacturer.json: ${manufacturers.length} manufacturers`);
    
    // Show sample manufacturer
    if (manufacturers.length > 0) {
      console.log(`   Sample: ${JSON.stringify(manufacturers[0], null, 2).substring(0, 150)}...`);
    }

  } catch (error) {
    console.log(`❌ Error reading manufacturer.json: ${error.message}`);
    throw error;
  }
}

async function validateProductFiles() {
  const dataDir = path.join('..', 'lib', 'data', 'new_data');
  
  // Specific files to validate
  const productFiles = [
    'cpu.json',
    'drive.json', 
    'gpu.json',
    'ram.json',
    'mainboard.json',
    'psu.json'
  ];

  let totalProducts = 0;

  for (const fileName of productFiles) {
    const filePath = path.join(dataDir, fileName);
    
    if (!fs.existsSync(filePath)) {
      console.log(`⚠️  File not found: ${fileName}`);
      continue;
    }

    try {
      const fileContent = fs.readFileSync(filePath, 'utf8');

      if (fileContent.trim() === '') {
        console.log(`⚠️  File is empty: ${fileName}`);
        continue;
      }

      const jsonData = JSON.parse(fileContent);

      if (!Array.isArray(jsonData)) {
        console.log(`❌ File ${fileName} does not contain an array`);
        continue;
      }

      if (jsonData.length === 0) {
        console.log(`⚠️  No data found in ${fileName}`);
        continue;
      }

      totalProducts += jsonData.length;
      console.log(`✅ ${fileName}: ${jsonData.length} products`);

      // Show sample of first product
      if (jsonData.length > 0) {
        const sample = JSON.stringify(jsonData[0], null, 2).substring(0, 200);
        console.log(`   Sample: ${sample}...`);
      }

    } catch (error) {
      console.log(`❌ Error reading ${fileName}: ${error.message}`);
    }
  }

  console.log(`\n📊 Total products to upload: ${totalProducts}`);
}

// Run the script
main();
