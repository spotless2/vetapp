module.exports = (sequelize, DataTypes) => {
    const Visit = sequelize.define('Visit', {
        visitReason: {
            type: DataTypes.STRING,
            allowNull: false
        },
        observations: {
            type: DataTypes.TEXT,
            allowNull: true
        },
        diagnosis: {
            type: DataTypes.TEXT,
            allowNull: true
        },
        recommendations: {
            type: DataTypes.TEXT,
            allowNull: true
        },
        animal: {
            type: DataTypes.JSON, // Store animal as a JSON object
            allowNull: false
        },
        treatment: {
            type: DataTypes.JSON, // Store treatment as a JSON object
            allowNull: true
        },
        treatmentQuantity: {
            type: DataTypes.STRING,
            allowNull: true
        },
        procedures: {
            type: DataTypes.JSON, // Store procedures as a JSON array
            allowNull: true
        },
        client: {
            type: DataTypes.JSON, // Store client as a JSON object
            allowNull: false
        },
        clientId: {
            type: DataTypes.INTEGER,
            allowNull: false, // Keep clientId as NOT NULL
            references: {
                model: 'Clients',
                key: 'id'
            }
        },
        isDeleted: {
            type: DataTypes.BOOLEAN,
            allowNull: false,
            defaultValue: false
        },
        createdBy: {
            type: DataTypes.STRING,
            allowNull: true, // Optional field
        },
        updatedBy: {
            type: DataTypes.STRING,
            allowNull: true, // Optional field
        }
    }, {
        timestamps: true
    });

    Visit.associate = models => {
        Visit.belongsTo(models.Client, { foreignKey: 'clientId' });
    };

    return Visit;
};