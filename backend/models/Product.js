module.exports = (sequelize, DataTypes) => {
    const Product = sequelize.define('Product', {
        name: {
            type: DataTypes.STRING,
            allowNull: false
        },
        category: {
            type: DataTypes.ENUM(
                'Medicamente',
                'Materiale Chirurgicale',
                'Consumabile',
                'Echipamente',
                'Alimente',
                'Suplimente',
                'Igienă',
                'Altele'
            ),
            allowNull: false,
            defaultValue: 'Consumabile'
        },
        description: {
            type: DataTypes.TEXT,
            allowNull: true
        },
        sku: {
            type: DataTypes.STRING,
            allowNull: true,
            unique: true
        },
        barcode: {
            type: DataTypes.STRING,
            allowNull: true
        },
        manufacturer: {
            type: DataTypes.STRING,
            allowNull: true
        },
        supplier: {
            type: DataTypes.STRING,
            allowNull: true
        },
        unitPrice: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: false,
            defaultValue: 0.00
        },
        priceWithVAT: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: false,
            defaultValue: 0.00
        },
        vatRate: {
            type: DataTypes.DECIMAL(5, 2),
            allowNull: false,
            defaultValue: 19.00 // 19% TVA implicit
        },
        quantity: {
            type: DataTypes.INTEGER,
            allowNull: false,
            defaultValue: 0
        },
        minQuantity: {
            type: DataTypes.INTEGER,
            allowNull: false,
            defaultValue: 0
        },
        maxQuantity: {
            type: DataTypes.INTEGER,
            allowNull: true
        },
        unit: {
            type: DataTypes.ENUM('buc', 'cutie', 'flacon', 'kg', 'g', 'l', 'ml', 'pachet', 'set'),
            allowNull: false,
            defaultValue: 'buc'
        },
        expiryDate: {
            type: DataTypes.DATE,
            allowNull: true
        },
        batchNumber: {
            type: DataTypes.STRING,
            allowNull: true
        },
        location: {
            type: DataTypes.STRING,
            allowNull: true
        },
        notes: {
            type: DataTypes.TEXT,
            allowNull: true
        },
        isActive: {
            type: DataTypes.BOOLEAN,
            allowNull: false,
            defaultValue: true
        },
        cabinetId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'Cabinets',
                key: 'id'
            },
            onDelete: 'CASCADE',
            onUpdate: 'CASCADE'
        },
        createdBy: {
            type: DataTypes.INTEGER,
            allowNull: true,
            references: {
                model: 'Users',
                key: 'id'
            },
            onDelete: 'SET NULL',
            onUpdate: 'CASCADE'
        },
        updatedBy: {
            type: DataTypes.INTEGER,
            allowNull: true,
            references: {
                model: 'Users',
                key: 'id'
            },
            onDelete: 'SET NULL',
            onUpdate: 'CASCADE'
        }
    }, {
        timestamps: true,
        indexes: [
            {
                fields: ['cabinetId']
            },
            {
                fields: ['category']
            },
            {
                fields: ['isActive']
            }
        ]
    });

    Product.associate = (models) => {
        Product.belongsTo(models.Cabinet, {
            foreignKey: 'cabinetId',
            as: 'cabinet'
        });
        Product.belongsTo(models.User, {
            foreignKey: 'createdBy',
            as: 'creator'
        });
        Product.belongsTo(models.User, {
            foreignKey: 'updatedBy',
            as: 'updater'
        });
    };

    return Product;
};
