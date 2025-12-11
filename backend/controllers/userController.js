const { User, Cabinet } = require("../models");

const getUserById = async (req, res) => {
    const { userId } = req.params;
  
    try {
      const user = await User.findByPk(userId, {
        attributes: { exclude: ['password'] },
        include: [
          {
            model: Cabinet,
            as: 'Cabinet',
            attributes: ['id', 'name', 'address']
          }
        ]
      });
  
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
  
      res.json(user);
    } catch (err) {
      res.status(500).json({ message: 'Server error', error: err.message });
    }
  };

const updateUser = async (req, res) => {
    const { userId } = req.params;
    const { username, email, firstName, middleName, lastName } = req.body;

    console.log('🔄 UPDATE User:', userId, 'Data:', req.body);

    try {
      const user = await User.findByPk(userId);

      if (!user) {
        console.log('❌ User not found');
        return res.status(404).json({ message: 'User not found' });
      }

      await user.update({
        username,
        email,
        firstName,
        middleName,
        lastName
      });

      console.log('✅ User updated successfully');

      // Return updated user without password
      const updatedUser = await User.findByPk(userId, {
        attributes: { exclude: ['password'] },
        include: [
          {
            model: Cabinet,
            as: 'Cabinet',
            attributes: ['id', 'name', 'address']
          }
        ]
      });

      res.json(updatedUser);
    } catch (err) {
      console.error('❌ Error updating user:', err.message);
      res.status(500).json({ message: 'Server error', error: err.message });
    }
  };
  
  module.exports = { getUserById, updateUser };