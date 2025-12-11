const express = require('express');
const router = express.Router();
const {
    createProduct,
    getProductsByCabinet,
    getProductsWithFilters,
    getProductById,
    updateProduct,
    updateProductQuantity,
    deleteProduct,
    bulkDeleteProducts,
    getInventoryStats
} = require('../controllers/productController');

// Create a new product
router.post('/', createProduct);

// Get all products for a cabinet
router.get('/cabinet/:cabinetId', getProductsByCabinet);

// Get products with filters
router.get('/cabinet/:cabinetId/filter', getProductsWithFilters);

// Get inventory statistics
router.get('/cabinet/:cabinetId/stats', getInventoryStats);

// Get single product by ID
router.get('/:id', getProductById);

// Update product
router.put('/:id', updateProduct);

// Update product quantity
router.put('/:id/quantity', updateProductQuantity);

// Delete product
router.delete('/:id', deleteProduct);

// Bulk delete products
router.post('/bulk-delete', bulkDeleteProducts);

module.exports = router;
