const { Cabinet } = require('../models');

// Fetch all cabinets
const getAllCabinets = async (req, res) => {
    try {
        const cabinets = await Cabinet.findAll();
        res.status(200).json(cabinets);
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

// Create a new cabinet
const createCabinet = async (req, res) => {
    const { name, address } = req.body;

    try {
        const newCabinet = await Cabinet.create({
            name,
            address
        });

        res.status(201).json(newCabinet);
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

module.exports = { getAllCabinets, createCabinet };