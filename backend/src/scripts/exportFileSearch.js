#!/usr/bin/env node
/**
 * Export Script for OpenAI File Search
 *
 * Exports product data from MongoDB to JSON files for upload to OpenAI Vector Store
 *
 * Usage:
 *   node src/scripts/exportFileSearch.js [options]
 *
 * Options:
 *   --brand <brand>      Filter by brand (iPhone, Samsung, Xiaomi, OPPO, Vivo)
 *   --condition <cond>   Filter by condition (new, likenew, used)
 *   --date <YYYY-MM-DD>  Export date folder name (default: today)
 *   --output <path>      Output directory (default: ./exports)
 *   --help               Show help
 */

const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');
require('dotenv').config();

// Import models (needed to register with mongoose)
require('../models/Product');
require('../models/Review');
require('../models/Coupon');
require('../models/User');

// Import export service
const {
  generateProductDocument,
  generateMetadataAttributes,
  generateAttributesSchema,
  getProductsForExport
} = require('../services/fileSearchExport');

/**
 * Parse command line arguments
 */
function parseArgs() {
  const args = process.argv.slice(2);
  const options = {
    brand: null,
    condition: null,
    date: new Date().toISOString().split('T')[0],
    output: './exports'
  };

  for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--brand':
        options.brand = args[++i];
        break;
      case '--condition':
        options.condition = args[++i];
        break;
      case '--date':
        options.date = args[++i];
        break;
      case '--output':
        options.output = args[++i];
        break;
      case '--help':
        printHelp();
        process.exit(0);
    }
  }

  return options;
}

/**
 * Print help message
 */
function printHelp() {
  console.log(`
Export Script for OpenAI File Search

Exports product data from MongoDB to JSON files for upload to OpenAI Vector Store

Usage:
  node src/scripts/exportFileSearch.js [options]

Options:
  --brand <brand>      Filter by brand (iPhone, Samsung, Xiaomi, OPPO, Vivo)
  --condition <cond>   Filter by condition (new, likenew, used)
  --date <YYYY-MM-DD>  Export date folder name (default: today)
  --output <path>      Output directory (default: ./exports)
  --help               Show help

Examples:
  # Export all products
  npm run export:filesearch

  # Export only iPhones
  npm run export:filesearch -- --brand iPhone

  # Export to custom directory
  npm run export:filesearch -- --output ./my-exports
`);
}

/**
 * Create directory if it doesn't exist
 */
function ensureDir(dirPath) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }
}

/**
 * Write JSON file
 */
function writeJsonFile(filePath, data) {
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf8');
}

/**
 * Main export function
 */
async function exportFileSearch(options) {
  const startTime = Date.now();

  console.log('='.repeat(60));
  console.log('OpenAI File Search Export');
  console.log('='.repeat(60));
  console.log(`Date: ${options.date}`);
  if (options.brand) console.log(`Brand filter: ${options.brand}`);
  if (options.condition) console.log(`Condition filter: ${options.condition}`);
  console.log('');

  // Setup output directories
  const exportDir = path.join(options.output, options.date);
  const productsDir = path.join(exportDir, 'products');
  ensureDir(productsDir);

  console.log(`Output directory: ${exportDir}`);
  console.log('');

  // Get products to export
  const filters = {};
  if (options.brand) filters.brand = options.brand;
  if (options.condition) filters.condition = options.condition;

  const products = await getProductsForExport(filters);
  const totalProducts = products.length;

  console.log(`Found ${totalProducts} products to export`);
  console.log('-'.repeat(60));

  // Export tracking
  const exportLog = {
    export_date: options.date,
    started_at: new Date().toISOString(),
    filters: filters,
    total_products: totalProducts,
    success_count: 0,
    error_count: 0,
    products: [],
    errors: []
  };

  const manifest = {
    export_date: options.date,
    generated_at: new Date().toISOString(),
    total_files: 0,
    files: []
  };

  // Export each product
  for (let i = 0; i < products.length; i++) {
    const product = products[i];
    const progress = `[${i + 1}/${totalProducts}]`;

    try {
      // Generate document
      const document = await generateProductDocument(product._id);
      const attributes = generateMetadataAttributes(document);

      // Remove internal fields before writing to file
      delete document._sentimentSummary;

      // Write JSON file
      const fileName = `product_${product._id}.json`;
      const filePath = path.join(productsDir, fileName);
      writeJsonFile(filePath, document);

      // Update tracking
      exportLog.success_count++;
      exportLog.products.push({
        product_id: product._id.toString(),
        name: product.name,
        brand: product.brand,
        file: fileName,
        status: 'success'
      });

      manifest.files.push({
        file: fileName,
        product_id: product._id.toString(),
        attributes: attributes
      });

      console.log(`${progress} ✓ ${product.name}`);

    } catch (error) {
      exportLog.error_count++;
      exportLog.errors.push({
        product_id: product._id.toString(),
        name: product.name,
        error: error.message
      });

      console.error(`${progress} ✗ ${product.name}: ${error.message}`);
    }
  }

  // Write attributes schema
  const attributesSchema = generateAttributesSchema();
  writeJsonFile(path.join(exportDir, 'attributes_schema.json'), attributesSchema);

  // Update manifest
  manifest.total_files = exportLog.success_count;
  writeJsonFile(path.join(exportDir, 'manifest.json'), manifest);

  // Finalize export log
  exportLog.completed_at = new Date().toISOString();
  exportLog.duration_ms = Date.now() - startTime;
  writeJsonFile(path.join(exportDir, 'export_log.json'), exportLog);

  // Print summary
  console.log('');
  console.log('-'.repeat(60));
  console.log('EXPORT COMPLETE');
  console.log('-'.repeat(60));
  console.log(`Total: ${totalProducts}`);
  console.log(`Success: ${exportLog.success_count}`);
  console.log(`Errors: ${exportLog.error_count}`);
  console.log(`Duration: ${(exportLog.duration_ms / 1000).toFixed(2)}s`);
  console.log('');
  console.log('Output files:');
  console.log(`  - ${productsDir}/ (${exportLog.success_count} product files)`);
  console.log(`  - ${path.join(exportDir, 'attributes_schema.json')}`);
  console.log(`  - ${path.join(exportDir, 'manifest.json')}`);
  console.log(`  - ${path.join(exportDir, 'export_log.json')}`);
  console.log('');

  return exportLog;
}

/**
 * Connect to MongoDB and run export
 */
async function main() {
  const options = parseArgs();

  // Connect to MongoDB
  const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/veritashop';
  console.log('Connecting to MongoDB...');

  try {
    await mongoose.connect(mongoUri);
    console.log('Connected to MongoDB');
    console.log('');

    // Run export
    const result = await exportFileSearch(options);

    // Exit with appropriate code
    if (result.error_count > 0) {
      process.exit(1);
    }
    process.exit(0);

  } catch (error) {
    console.error('Export failed:', error.message);
    process.exit(1);
  } finally {
    await mongoose.disconnect();
  }
}

// Run if executed directly
if (require.main === module) {
  main();
}

module.exports = { exportFileSearch };
