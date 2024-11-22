const express = require('express');
const { createClient, getClientsByCabinetId, updateClient } = require('../controllers/clientController');

const router = express.Router();

router.post('/', createClient);
router.get('/:cabinetId', getClientsByCabinetId);
router.put('/:id', updateClient);

module.exports = router;