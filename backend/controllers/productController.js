const { Product, Cabinet } = require('../models');
const { Op } = require('sequelize');

// 📝 Create a new product
const createProduct = async (req, res) => {
    console.log('📝 CREATE Product received:', req.body);
    
    const {
        name,
        category,
        description,
        sku,
        barcode,
        manufacturer,
        supplier,
        unitPrice,
        vatRate,
        quantity,
        minQuantity,
        maxQuantity,
        unit,
        expiryDate,
        batchNumber,
        location,
        notes,
        isActive,
        cabinetId,
        createdBy
    } = req.body;

    try {
        // Calculate price with VAT
        const priceWithVAT = unitPrice * (1 + vatRate / 100);

        const newProduct = await Product.create({
            name,
            category,
            description,
            sku,
            barcode,
            manufacturer,
            supplier,
            unitPrice,
            priceWithVAT,
            vatRate,
            quantity,
            minQuantity,
            maxQuantity,
            unit,
            expiryDate,
            batchNumber,
            location,
            notes,
            isActive: isActive !== undefined ? isActive : true,
            cabinetId,
            createdBy
        });

        console.log('✅ Product created successfully:', newProduct.id);
        res.status(201).json(newProduct);
    } catch (err) {
        console.error('❌ Error creating product:', err.message);
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

// 📋 Get all products by cabinetId
const getProductsByCabinet = async (req, res) => {
    const { cabinetId } = req.params;
    console.log('📋 GET Products for cabinet:', cabinetId);

    try {
        const products = await Product.findAll({
            where: { cabinetId },
            order: [['name', 'ASC']],
            include: [
                {
                    model: Cabinet,
                    as: 'cabinet',
                    attributes: ['id', 'name']
                }
            ]
        });

        console.log(`✅ Found ${products.length} products`);
        res.status(200).json(products);
    } catch (err) {
        console.error('❌ Error fetching products:', err.message);
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

// 🔍 Get products with filters
const getProductsWithFilters = async (req, res) => {
    const { cabinetId } = req.params;
    const { category, search, lowStock, expired } = req.query;
    
    console.log('🔍 GET Products with filters:', { cabinetId, category, search, lowStock, expired });

    try {
        const whereConditions = { cabinetId };

        // Filter by category
        if (category && category !== 'Toate') {
            whereConditions.category = category;
        }

        // Search by name, manufacturer, or SKU
        if (search) {
            whereConditions[Op.or] = [
                { name: { [Op.like]: `%${search}%` } },
                { manufacturer: { [Op.like]: `%${search}%` } },
                { sku: { [Op.like]: `%${search}%` } }
            ];
        }

        // Filter low stock items
        if (lowStock === 'true') {
            whereConditions[Op.and] = [
                { quantity: { [Op.lte]: sequelize.col('minQuantity') } }
            ];
        }

        // Filter expired products
        if (expired === 'true') {
            whereConditions.expiryDate = { [Op.lte]: new Date() };
        }

        const products = await Product.findAll({
            where: whereConditions,
            order: [['name', 'ASC']]
        });

        console.log(`✅ Found ${products.length} filtered products`);
        res.status(200).json(products);
    } catch (err) {
        console.error('❌ Error fetching filtered products:', err.message);
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

// 📄 Get single product by ID
const getProductById = async (req, res) => {
    const { id } = req.params;
    console.log('📄 GET Product by ID:', id);

    try {
        const product = await Product.findByPk(id, {
            include: [
                {
                    model: Cabinet,
                    as: 'cabinet',
                    attributes: ['id', 'name']
                }
            ]
        });

        if (!product) {
            console.log('❌ Product not found');
            return res.status(404).json({ message: 'Product not found' });
        }

        console.log('✅ Product found:', product.name);
        res.status(200).json(product);
    } catch (err) {
        console.error('❌ Error fetching product:', err.message);
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

// 🔄 Update product
const updateProduct = async (req, res) => {
    const { id } = req.params;
    console.log('🔄 UPDATE Product:', id, 'Data:', req.body);

    try {
        const product = await Product.findByPk(id);

        if (!product) {
            console.log('❌ Product not found');
            return res.status(404).json({ message: 'Product not found' });
        }

        const {
            unitPrice,
            vatRate,
            ...otherFields
        } = req.body;

        // Recalculate price with VAT if unitPrice or vatRate changed
        let priceWithVAT = product.priceWithVAT;
        if (unitPrice !== undefined || vatRate !== undefined) {
            const newUnitPrice = unitPrice !== undefined ? unitPrice : product.unitPrice;
            const newVatRate = vatRate !== undefined ? vatRate : product.vatRate;
            priceWithVAT = newUnitPrice * (1 + newVatRate / 100);
        }

        await product.update({
            ...otherFields,
            ...(unitPrice !== undefined && { unitPrice }),
            ...(vatRate !== undefined && { vatRate }),
            priceWithVAT
        });

        console.log('✅ Product updated successfully');
        res.status(200).json(product);
    } catch (err) {
        console.error('❌ Error updating product:', err.message);
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

// ➕ Update product quantity (add/subtract)
const updateProductQuantity = async (req, res) => {
    const { id } = req.params;
    const { quantity, operation } = req.body; // operation: 'add' or 'subtract'
    
    console.log('➕ UPDATE Quantity for product:', id, 'Operation:', operation, 'Amount:', quantity);

    try {
        const product = await Product.findByPk(id);

        if (!product) {
            console.log('❌ Product not found');
            return res.status(404).json({ message: 'Product not found' });
        }

        let newQuantity = product.quantity;

        if (operation === 'add') {
            newQuantity += quantity;
        } else if (operation === 'subtract') {
            newQuantity = Math.max(0, newQuantity - quantity);
        } else {
            newQuantity = quantity;
        }

        await product.update({ quantity: newQuantity });

        console.log('✅ Quantity updated:', product.quantity, '→', newQuantity);
        res.status(200).json(product);
    } catch (err) {
        console.error('❌ Error updating quantity:', err.message);
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

// 🗑️ Delete product
const deleteProduct = async (req, res) => {
    const { id } = req.params;
    console.log('🗑️ DELETE Product:', id);

    try {
        const product = await Product.findByPk(id);

        if (!product) {
            console.log('❌ Product not found');
            return res.status(404).json({ message: 'Product not found' });
        }

        await product.destroy();

        console.log('✅ Product deleted successfully');
        res.status(200).json({ message: 'Product deleted successfully' });
    } catch (err) {
        console.error('❌ Error deleting product:', err.message);
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

// 🔄 Bulk delete products
const bulkDeleteProducts = async (req, res) => {
    const { ids } = req.body;
    console.log('🔄 BULK DELETE Products:', ids);

    try {
        if (!Array.isArray(ids) || ids.length === 0) {
            return res.status(400).json({ message: 'Invalid product IDs' });
        }

        const deleted = await Product.destroy({
            where: {
                id: { [Op.in]: ids }
            }
        });

        console.log(`✅ Deleted ${deleted} products`);
        res.status(200).json({ message: `${deleted} products deleted successfully`, count: deleted });
    } catch (err) {
        console.error('❌ Error bulk deleting products:', err.message);
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

// 📊 Get inventory statistics
const getInventoryStats = async (req, res) => {
    const { cabinetId } = req.params;
    console.log('📊 GET Inventory stats for cabinet:', cabinetId);

    try {
        const products = await Product.findAll({
            where: { cabinetId }
        });

        const totalProducts = products.length;
        const totalValue = products.reduce((sum, p) => sum + (p.unitPrice * p.quantity), 0);
        const lowStockCount = products.filter(p => p.quantity <= p.minQuantity).length;
        const expiredCount = products.filter(p => p.expiryDate && new Date(p.expiryDate) <= new Date()).length;
        const activeProducts = products.filter(p => p.isActive).length;

        const stats = {
            totalProducts,
            activeProducts,
            totalValue: totalValue.toFixed(2),
            lowStockCount,
            expiredCount
        };

        console.log('✅ Stats calculated:', stats);
        res.status(200).json(stats);
    } catch (err) {
        console.error('❌ Error calculating stats:', err.message);
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

module.exports = {
    createProduct,
    getProductsByCabinet,
    getProductsWithFilters,
    getProductById,
    updateProduct,
    updateProductQuantity,
    deleteProduct,
    bulkDeleteProducts,
    getInventoryStats
};
