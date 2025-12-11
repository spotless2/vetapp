const express = require('express');
const bodyParser = require('body-parser');
const { sequelize } = require('./models');
const multer = require('multer');
const path = require('path');
const cors = require('cors');

const authRoutes = require('./routes/auth');
const cabinetRoutes = require('./routes/cabinet');
const userRoutes = require('./routes/user');
const clientRoutes = require('./routes/client');
const petRoutes = require('./routes/pet');
const visitRoutes = require('./routes/visit');
const appointmentRoutes = require('./routes/appointment');
const productRoutes = require('./routes/product');

require('dotenv').config();

const app = express();
const port = 3000;

// Enable CORS
app.use(cors());

// Middleware to parse JSON bodies
app.use(bodyParser.json());

// Set up multer for file uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        cb(null, `${Date.now()}-${file.originalname}`);
    }
});
const upload = multer({ storage });

app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Routes
app.use('/auth/register', upload.single('photo'), authRoutes);
app.use('/auth', authRoutes);
app.use('/cabinets', cabinetRoutes);
app.use('/users', userRoutes);
app.use('/clients', clientRoutes);
app.use('/pets', petRoutes);
app.use('/visits', visitRoutes);
app.use('/appointments', appointmentRoutes);
app.use('/products', productRoutes);

app.get('/', (req, res) => {
    res.send('Hello World!');
});

// NOTE: If you encounter foreign key errors after adding userType field,
// run these SQL commands manually:
// SET FOREIGN_KEY_CHECKS=0;
// ALTER TABLE Users MODIFY cabinetId INT NULL;
// ALTER TABLE Users ADD COLUMN IF NOT EXISTS userType ENUM('doctor', 'client') NOT NULL DEFAULT 'doctor' AFTER lastName;
// UPDATE Users SET userType = 'doctor' WHERE cabinetId IS NOT NULL;
// SET FOREIGN_KEY_CHECKS=1;

sequelize.sync().then(() => {
    app.listen(port, () => {
        console.log(`Server is running on http://localhost:${port}`);
    });
}).catch(err => {
    console.error('Error synchronizing database:', err);
});