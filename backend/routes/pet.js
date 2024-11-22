const express = require('express');
const { createPet, getPetsByClientId, updatePet, deletePet } = require('../controllers/petController');

const router = express.Router();

router.post('/', createPet);
router.get('/client/:clientId', getPetsByClientId);
router.put('/:petId', updatePet); // Add route for updating an existing pet
router.delete('/:petId', deletePet); // Add route for deleting an existing pet

module.exports = router;