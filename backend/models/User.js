module.exports = (sequelize, DataTypes) => {
    const User = sequelize.define('User', {
        username: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true
        },
        password: {
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
        firstName: {
            type: DataTypes.STRING,
            allowNull: false
        },
        middleName: {
            type: DataTypes.STRING,
            allowNull: true
        },
        lastName: {
            type: DataTypes.STRING,
            allowNull: false
        },
        userType: {
            type: DataTypes.ENUM('doctor', 'client'),
            allowNull: false,
            defaultValue: 'client'
        },
        cabinetId: {
            type: DataTypes.INTEGER,
            allowNull: true,
            references: {
                model: 'Cabinets',
                key: 'id'
            },
            onDelete: 'SET NULL',
            onUpdate: 'CASCADE'
        },
        photo: {
            type: DataTypes.STRING,
            allowNull: true
        }
    }, {
        timestamps: true
    });

    User.associate = models => {
        User.belongsTo(models.Cabinet, { foreignKey: 'cabinetId', as: 'Cabinet' });
        User.hasMany(models.Client, { foreignKey: 'createdBy' });
    };

    return User;
};