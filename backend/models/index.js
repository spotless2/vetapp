const { Sequelize, DataTypes } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASSWORD, {
    host: process.env.DB_HOST,
    dialect: 'mysql'
});

const db = {};
db.Sequelize = Sequelize;
db.sequelize = sequelize;

db.User = require('./User')(sequelize, DataTypes);
db.Cabinet = require('./Cabinet')(sequelize, DataTypes);
db.Client = require('./Client')(sequelize, DataTypes);
db.Pet = require('./Pet')(sequelize, DataTypes);
db.Visit = require('./Visit')(sequelize, DataTypes);

// Define associations
if (db.User.associate) db.User.associate(db);
if (db.Cabinet.associate) db.Cabinet.associate(db);
if (db.Client.associate) db.Client.associate(db);
if (db.Pet.associate) db.Pet.associate(db);
if (db.Visit.associate) db.Visit.associate(db);

// Synchronize database schema
sequelize.sync({ alter: true })
    .then(() => {
        console.log('Database synchronized');
    })
    .catch(err => {
        console.error('Error synchronizing database:', err);
    });

module.exports = db;