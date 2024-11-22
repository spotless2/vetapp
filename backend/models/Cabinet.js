const { DataTypes } = require("sequelize");

module.exports = (sequelize, DataTypes) => {
    const Cabinet = sequelize.define('Cabinet', {
        name: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true
        },
        address: {
            type: DataTypes.STRING,
            allowNull: false
        }
    }, {
        timestamps: true // This ensures Sequelize manages createdAt and updatedAt fields
    });

    Cabinet.associate = models => {
        Cabinet.hasMany(models.Client, { foreignKey: 'cabinetId' });
    };

    return Cabinet;
};