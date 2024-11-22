const { User } = require("../models");

const getUserById = async (req, res) => {
    const { userId } = req.params;
  
    try {
      const user = await User.findByPk(userId, {
        attributes: { exclude: ['password'] } // Exclude the password field
      });
  
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
  
      res.json(user);
    } catch (err) {
      res.status(500).json({ message: 'Server error', error: err.message });
    }
  };
  
  module.exports = { getUserById };