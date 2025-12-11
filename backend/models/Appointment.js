module.exports = (sequelize, DataTypes) => {
    const Appointment = sequelize.define('Appointment', {
        title: {
            type: DataTypes.STRING,
            allowNull: false
        },
        startTime: {
            type: DataTypes.DATE,
            allowNull: false
        },
        endTime: {
            type: DataTypes.DATE,
            allowNull: false
        },
        type: {
            type: DataTypes.ENUM('appointment', 'blocked'),
            allowNull: false,
            defaultValue: 'appointment'
        },
        status: {
            type: DataTypes.ENUM('scheduled', 'confirmed', 'completed', 'cancelled'),
            allowNull: false,
            defaultValue: 'scheduled'
        },
        clientName: {
            type: DataTypes.STRING,
            allowNull: true // null for blocked slots
        },
        clientPhone: {
            type: DataTypes.STRING,
            allowNull: true // null for blocked slots
        },
        clientEmail: {
            type: DataTypes.STRING,
            allowNull: true // optional
        },
        reason: {
            type: DataTypes.TEXT,
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
        timestamps: true
    });

    Appointment.associate = models => {
        Appointment.belongsTo(models.Cabinet, { foreignKey: 'cabinetId' });
        Appointment.belongsTo(models.User, { foreignKey: 'createdBy', as: 'creator' });
        Appointment.belongsTo(models.User, { foreignKey: 'updatedBy', as: 'updater' });
    };

    return Appointment;
};
