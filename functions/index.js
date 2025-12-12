const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const { onCall } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp();
const db = getFirestore();

/**
 * Cloud Function to aggregate dashboard statistics.
 * Called when a sales invoice is created, updated, or deleted.
 * Stores precomputed stats in aggregations/dashboard document.
 */
exports.aggregateDashboardStats = onDocumentWritten(
  'sales_invoices/{invoiceId}',
  async (event) => {
    await updateDashboardStats();
  }
);

/**
 * HTTP-callable function to manually recalculate dashboard stats.
 * Useful for initial setup or fixing data inconsistencies.
 */
exports.recalculateDashboardStats = onCall(async (request) => {
  await updateDashboardStats();
  return { success: true, message: 'Dashboard stats recalculated' };
});

/**
 * Scheduled function to recalculate stats daily at midnight.
 * Ensures data consistency even if triggers are missed.
 */
exports.scheduledDashboardStatsUpdate = onSchedule(
  {
    schedule: '0 0 * * *',
    timeZone: 'Asia/Ho_Chi_Minh',
  },
  async (event) => {
    await updateDashboardStats();
  }
);

/**
 * Cloud Function to count products by category.
 * Called when a product is created, updated, or deleted.
 * Stores precomputed counts in aggregations/productCounts document.
 */
exports.aggregateProductCounts = onDocumentWritten(
  'products/{productId}',
  async (event) => {
    await updateProductCounts();
  }
);

/**
 * HTTP-callable function to manually recalculate product counts.
 * Useful for initial setup or fixing data inconsistencies.
 */
exports.recalculateProductCounts = onCall(async (request) => {
  await updateProductCounts();
  return { success: true, message: 'Product counts recalculated' };
});

/**
 * Scheduled function to recalculate product counts daily at midnight.
 * Ensures data consistency even if triggers are missed.
 */
exports.scheduledProductCountsUpdate = onSchedule(
  {
    schedule: '0 0 * * *',
    timeZone: 'Asia/Ho_Chi_Minh',
  },
  async (event) => {
    await updateProductCounts();
  }
);

/**
 * Main function to calculate and store aggregated dashboard statistics.
 */
async function updateDashboardStats() {
  try {
    // Get all sales invoices
    const invoicesSnapshot = await db.collection('sales_invoices').get();
    
    let totalRevenue = 0;
    let totalOrders = 0;
    const monthlySales = {}; // { "2024-01": amount, "2024-02": amount, ... }
    const dailySales = {}; // { "2024-01-15": amount, "2024-01-16": amount, ... }
    const monthlySalesByCategory = {}; // { "2024-01": { "RAM": amount, "CPU": amount, ... }, ... }
    const dailySalesByCategory = {}; // { "2024-01-15": { "RAM": amount, "CPU": amount, ... }, ... }
    
    // Process each invoice
    for (const doc of invoicesSnapshot.docs) {
      const invoice = doc.data();
      
      // Only count paid invoices for revenue
      if (invoice.paymentStatus === 'paid') {
        const amount = invoice.totalPrice || 0;
        totalRevenue += amount;
        totalOrders++;
        
        // Aggregate sales by date
        if (invoice.date) {
          let invoiceDate;
          
          // Handle Firestore Timestamp or string date
          if (invoice.date.toDate) {
            invoiceDate = invoice.date.toDate();
          } else if (invoice.date.seconds) {
            invoiceDate = new Date(invoice.date.seconds * 1000);
          } else {
            invoiceDate = new Date(invoice.date);
          }
          
          const year = invoiceDate.getFullYear();
          const month = (invoiceDate.getMonth() + 1).toString().padStart(2, '0');
          const day = invoiceDate.getDate().toString().padStart(2, '0');
          
          // Monthly aggregation
          const monthKey = `${year}-${month}`;
          monthlySales[monthKey] = (monthlySales[monthKey] || 0) + amount;
          
          // Daily aggregation
          const dayKey = `${year}-${month}-${day}`;
          dailySales[dayKey] = (dailySales[dayKey] || 0) + amount;
          
          // Get invoice details for category aggregation
          try {
            const detailsSnapshot = await db.collection('sales_invoice_details')
              .where('salesInvoiceID', '==', doc.id)
              .get();
            
            // Collect all productIDs first
            const productIDs = new Set();
            const detailMap = new Map(); // Map productID -> {revenue, detail}
            
            for (const detailDoc of detailsSnapshot.docs) {
              const detail = detailDoc.data();
              const productID = detail.productID;
              const revenue = detail.subtotal || 0;
              
              if (productID) {
                productIDs.add(productID);
                if (!detailMap.has(productID)) {
                  detailMap.set(productID, []);
                }
                detailMap.get(productID).push({ revenue, detail });
              } else {
                // No productID, use category from detail directly
                const category = detail.category || 'Unknown';
                if (!monthlySalesByCategory[monthKey]) {
                  monthlySalesByCategory[monthKey] = {};
                }
                if (!dailySalesByCategory[dayKey]) {
                  dailySalesByCategory[dayKey] = {};
                }
                monthlySalesByCategory[monthKey][category] = 
                  (monthlySalesByCategory[monthKey][category] || 0) + revenue;
                dailySalesByCategory[dayKey][category] = 
                  (dailySalesByCategory[dayKey][category] || 0) + revenue;
              }
            }
            
            // Batch fetch all products
            const productCategoryMap = new Map(); // Map productID -> category
            if (productIDs.size > 0) {
              const productPromises = Array.from(productIDs).map(async (productID) => {
                try {
                  const productDoc = await db.collection('products').doc(productID).get();
                  if (productDoc.exists) {
                    const productData = productDoc.data();
                    return { productID, category: productData.category || 'Unknown' };
                  } else {
                    // Product not found, will use detail category as fallback
                    return { productID, category: null };
                  }
                } catch (error) {
                  console.warn(`Error fetching product ${productID}:`, error);
                  return { productID, category: null };
                }
              });
              
              const productResults = await Promise.all(productPromises);
              for (const result of productResults) {
                productCategoryMap.set(result.productID, result.category);
              }
            }
            
            // Now aggregate by category using the fetched product categories
            for (const [productID, details] of detailMap.entries()) {
              const category = productCategoryMap.get(productID) || 
                               (details[0].detail.category || 'Unknown');
              
              // Initialize category maps if needed
              if (!monthlySalesByCategory[monthKey]) {
                monthlySalesByCategory[monthKey] = {};
              }
              if (!dailySalesByCategory[dayKey]) {
                dailySalesByCategory[dayKey] = {};
              }
              
              // Sum up all revenues for this product in this invoice
              const totalRevenue = details.reduce((sum, d) => sum + d.revenue, 0);
              
              // Aggregate by category
              monthlySalesByCategory[monthKey][category] = 
                (monthlySalesByCategory[monthKey][category] || 0) + totalRevenue;
              dailySalesByCategory[dayKey][category] = 
                (dailySalesByCategory[dayKey][category] || 0) + totalRevenue;
            }
          } catch (error) {
            console.warn(`Error processing details for invoice ${doc.id}:`, error);
          }
        }
      }
    }
    
    // Convert monthly sales map to sorted array for easy consumption
    const monthlySalesArray = Object.entries(monthlySales)
      .map(([month, amount]) => ({ month, amount }))
      .sort((a, b) => a.month.localeCompare(b.month));
    
    // Convert daily sales map to sorted array (limit to last 90 days for performance)
    const dailySalesArray = Object.entries(dailySales)
      .map(([date, amount]) => ({ date, amount }))
      .sort((a, b) => a.date.localeCompare(b.date))
      .slice(-90); // Keep last 90 days
    
    // Convert monthly sales by category to array format
    const monthlySalesByCategoryArray = Object.entries(monthlySalesByCategory)
      .map(([month, categories]) => ({ 
        month, 
        categories: Object.entries(categories).map(([category, amount]) => ({ category, amount }))
      }))
      .sort((a, b) => a.month.localeCompare(b.month));
    
    // Convert daily sales by category to array format (limit to last 90 days)
    const dailySalesByCategoryArray = Object.entries(dailySalesByCategory)
      .map(([date, categories]) => ({ 
        date, 
        categories: Object.entries(categories).map(([category, amount]) => ({ category, amount }))
      }))
      .sort((a, b) => a.date.localeCompare(b.date))
      .slice(-90); // Keep last 90 days
    
    // Store the aggregated stats
    await db.collection('aggregations').doc('dashboard').set({
      totalRevenue,
      totalOrders,
      avgOrderValue: totalOrders > 0 ? totalRevenue / totalOrders : 0,
      monthlySales: monthlySalesArray,
      dailySales: dailySalesArray,
      monthlySalesByCategory: monthlySalesByCategoryArray,
      dailySalesByCategory: dailySalesByCategoryArray,
      lastUpdated: FieldValue.serverTimestamp(),
    }, { merge: true });
    
    console.log('Dashboard stats updated successfully:', {
      totalRevenue,
      totalOrders,
      monthsWithData: monthlySalesArray.length,
      daysWithData: dailySalesArray.length,
    });
    
  } catch (error) {
    console.error('Error updating dashboard stats:', error);
    throw error;
  }
}

/**
 * Main function to calculate and store product counts by category.
 * Gets category information from sales_invoice_details collection.
 */
async function updateProductCounts() {
  try {
    // Get all sales invoice details to extract product categories
    const detailsSnapshot = await db.collection('sales_invoice_details').get();
    
    // Map to store productID -> category (to avoid counting same product multiple times)
    const productCategoryMap = {}; // { "productId1": "RAM", "productId2": "CPU", ... }
    const categoryCounts = {}; // { "RAM": 10, "CPU": 5, ... }
    
    // Process each detail to get product categories
    detailsSnapshot.forEach(doc => {
      const detail = doc.data();
      const productID = detail.productID;
      const category = detail.category || 'Unknown';
      
      // Only store the first category we encounter for each product
      // (in case a product appears in multiple invoices with different categories)
      if (productID && !productCategoryMap[productID]) {
        productCategoryMap[productID] = category;
      }
    });
    
    // Count products by category
    for (const productID in productCategoryMap) {
      const category = productCategoryMap[productID];
      categoryCounts[category] = (categoryCounts[category] || 0) + 1;
    }
    
    // Convert to array format for easy consumption
    const categoryCountsArray = Object.entries(categoryCounts)
      .map(([category, count]) => ({ category, count }))
      .sort((a, b) => a.category.localeCompare(b.category));
    
    const totalProducts = Object.keys(productCategoryMap).length;
    
    // Store the aggregated counts
    await db.collection('aggregations').doc('productCounts').set({
      categoryCounts: categoryCountsArray,
      totalProducts: totalProducts,
      lastUpdated: FieldValue.serverTimestamp(),
    }, { merge: true });
    
    console.log('Product counts updated successfully:', {
      totalProducts: totalProducts,
      categories: Object.keys(categoryCounts).length,
      categoryCounts: categoryCounts,
    });
    
  } catch (error) {
    console.error('Error updating product counts:', error);
    throw error;
  }
}
