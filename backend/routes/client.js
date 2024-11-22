const express = require('express');
const { createClient, getClientsByCabinetId } = require('../controllers/clientController');

const router = express.Router();

router.post('/', createClient);
router.get('/:cabinetId', getClientsByCabinetId);

module.exports = router;