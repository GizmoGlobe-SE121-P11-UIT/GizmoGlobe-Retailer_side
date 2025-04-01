const fs = require('fs');
const path = require('path');
require('dotenv').config();

const template = {
  project_info: {
    project_number: process.env.GOOGLE_SERVICES_PROJECT_NUMBER,
    project_id: process.env.GOOGLE_SERVICES_PROJECT_ID,
    storage_bucket: process.env.GOOGLE_SERVICES_STORAGE_BUCKET
  },
  client: [
    {
      client_info: {
        mobilesdk_app_id: "1:413433346211:android:1155fb688243e1cd73a716",
        android_client_info: {
          package_name: "com.example.gizmoglobe_retailer"
        }
      },
      oauth_client: [
        {
          client_id: process.env.GOOGLE_SERVICES_CLIENT_ID,
          client_type: 1,
          android_info: {
            package_name: "com.example.gizmoglobe_retailer",
            certificate_hash: "c894737a03db30db6a50b5d0e7f1932f46c2d91a"
          }
        }
      ],
      api_key: [
        {
          current_key: process.env.GOOGLE_SERVICES_API_KEY
        }
      ]
    }
  ]
};

const outputPath = path.join(__dirname, '../android/app/google-services.json');
fs.writeFileSync(outputPath, JSON.stringify(template, null, 2));
console.log('Generated google-services.json successfully!'); 