module.exports = (sequelize, DataTypes) => {
    const Pet = sequelize.define('Pet', {
        name: {
            type: DataTypes.STRING,
            allowNull: false
        },
        species: {
            type: DataTypes.STRING,
            allowNull: false
        },
        breed: {
            type: DataTypes.STRING,
            allowNull: false
        },
        gender: {
            type: DataTypes.STRING,
            allowNull: false
        },
        birthDate: {
            type: DataTypes.DATE, // Store birthDate as a DATE type
            allowNull: false
        },
        color: {
            type: DataTypes.STRING,
            allowNull: false
        },
        reproductiveStatus: {
            type: DataTypes.STRING,
            allowNull: false
        },
        photo: {
            type: DataTypes.STRING,
            allowNull: true
        },
        allergies: {
            type: DataTypes.STRING,
            allowNull: true
        },
        distinctiveMarks: {
            type: DataTypes.STRING,
            allowNull: true
        },
        animalCardNumber: {
            type: DataTypes.STRING,
            allowNull: true
        },
        insuranceNumber: {
            type: DataTypes.STRING,
            allowNull: true
        },
        bloodGroup: {
            type: DataTypes.STRING,
            allowNull: true
        },
        microchipCode: {
            type: DataTypes.STRING,
            allowNull: true
        },
        passportSeries: {
            type: DataTypes.STRING,
            allowNull: true
        },
        description: {
            type: DataTypes.TEXT,
            allowNull: false
        },
        healthPlan: {
            type: DataTypes.STRING,
            allowNull: true
        },
        patientAlerts: {
            type: DataTypes.STRING,
            allowNull: true
        },
        internalNotes: {
            type: DataTypes.TEXT,
            allowNull: true
        },
        clientId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'Clients',
                key: 'id'
            }
        }
    }, {
        timestamps: true
    });

    Pet.associate = models => {
        Pet.belongsTo(models.Client, { foreignKey: 'clientId' });
    };

    return Pet;
};