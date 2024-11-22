module.exports = (sequelize, DataTypes) => {
    const Client = sequelize.define('Client', {
        firstName: {
            type: DataTypes.STRING,
            allowNull: false
        },
        lastName: {
            type: DataTypes.STRING,
            allowNull: false
        },
        email: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true,
            validate: {
                isEmail: true
            }
        },
        phone: {
            type: DataTypes.STRING,
            allowNull: false
        },
        personalId: {
            type: DataTypes.STRING,
            allowNull: true
        },
        idCardNumber: {
            type: DataTypes.STRING,
            allowNull: true
        },
        address: {
            type: DataTypes.STRING,
            allowNull: true
        },
        birthDate: {
            type: DataTypes.DATE,
            allowNull: true
        },
        notes: {
            type: DataTypes.TEXT,
            allowNull: true
        },
        cabinetId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'Cabinets',
                key: 'id'
            }
        },
        createdBy: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'Users',
                key: 'id'
            }
        },
        updatedBy: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'Users',
                key: 'id'
            }
        }

    }, {
        timestamps: true
    });

    Client.associate = models => {
        Client.belongsTo(models.Cabinet, { foreignKey: 'cabinetId' });
        Client.belongsTo(models.User, { foreignKey: 'createdBy' });
        Client.hasMany(models.Pet, { foreignKey: 'clientId' });
        Client.hasMany(models.Visit, { foreignKey: 'clientId' });
    };

    return Client;
};