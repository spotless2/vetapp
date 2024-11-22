const express = require('express');
const router = express.Router();
const { getAllCabinets, createCabinet } = require('../controllers/cabinetController'); 

router.get('/', getAllCabinets);
router.post('/', createCabinet); // Add route for creating a new cabinet

module.exports = router;