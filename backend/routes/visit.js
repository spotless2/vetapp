const express = require('express');
const { createVisit, getVisitsByClientId, updateVisit, softDeleteVisit, finalDeleteVisit } = require('../controllers/visitController');

const router = express.Router();

router.post('/', createVisit);
router.get('/client/:clientId', getVisitsByClientId);
router.put('/:visitId', updateVisit);
router.delete('/soft/:visitId', softDeleteVisit);
router.delete('/final/:visitId', finalDeleteVisit);

module.exports = router;