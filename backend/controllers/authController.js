const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { User, Cabinet, Sequelize } = require("../models");

// Register function
const register = async (req, res) => {
  const {
    username,
    password,
    email,
    firstName,
    middleName,
    lastName,
    cabinetId,
  } = req.body;

  const photo = req.file ? `/uploads/${req.file.filename}` : null;

  try {
    // Check if username already exists
    const existingUser = await User.findOne({ where: { username } });
    if (existingUser) {
      return res.status(400).json({ message: "Username already exists" });
    }

    // Check if email already exists
    const existingEmail = await User.findOne({ where: { email } });
    if (existingEmail) {
      return res.status(400).json({ message: "Email already exists" });
    }
    // Check if cabinetId exists
    const cabinet = await Cabinet.findByPk(cabinetId);
    if (!cabinet) {
        return res.status(400).json({ message: "Invalid cabinetId" });
    }
    // Hash the password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create new user
    const newUser = await User.create({
      username,
      password: hashedPassword,
      email,
      firstName,
      middleName,
      lastName,
      cabinetId,
      photo,
    });

    // Generate JWT token
    const token = jwt.sign(
      { id: newUser.id, username: newUser.username },
      process.env.JWT_SECRET,
      { expiresIn: "1h" }
    );

    res.status(201).json({ token });
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// Login function
const login = async (req, res) => {
  const { identifier, password } = req.body; // `identifier` can be either username or email

  try {
    // Find user by username or email
    const user = await User.findOne({
      where: {
        [Sequelize.Op.or]: [{ username: identifier }, { email: identifier }],
      },
    });

    if (!user) {
      return res.status(401).json({ message: "Authentication failed" });
    }

    // Compare password with hashed password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Authentication failed" });
    }

    // Generate JWT token
    const token = jwt.sign(
      { id: user.id, username: user.username, cabinetId: user.cabinetId, createdBy: user.createdBy },
      process.env.JWT_SECRET,
      { expiresIn: "1h" }
    );

    res.json({ token });
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

module.exports = { login, register };
