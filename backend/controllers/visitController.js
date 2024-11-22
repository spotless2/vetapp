const { Visit } = require('../models');

// Create a new visit
const createVisit = async (req, res) => {
    const { visitReason, observations, diagnosis, recommendations, animal, treatment, treatmentQuantity, procedures, client, clientId, createdBy} = req.body;

    try {
        const newVisit = await Visit.create({
            visitReason,
            observations,
            diagnosis,
            recommendations,
            animal,
            treatment,
            treatmentQuantity,
            procedures,
            client,
            clientId,
            createdBy,
            isDeleted: false
        });

        res.status(201).json(newVisit);
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

// Fetch visits by clientId
const getVisitsByClientId = async (req, res) => {
    const { clientId } = req.params;
    const { includeDeleted } = req.query; // Get the optional query parameter

    try {
        const whereClause = { clientId };
        if (includeDeleted === 'true') {
            // Include both deleted and non-deleted visits
            whereClause.isDeleted = true;
        } else {
            // Exclude deleted visits by default
            whereClause.isDeleted = false;
        }
        const visits = await Visit.findAll({ where: whereClause });
        res.status(200).json(visits);
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

// Update an existing visit
const updateVisit = async (req, res) => {
    const { visitId } = req.params;
    const { visitReason, observations, diagnosis, recommendations, animal, treatment, treatmentQuantity, procedures, client, updatedBy } = req.body;

    try {
        const visit = await Visit.findByPk(visitId);
        if (!visit) {
            return res.status(404).json({ message: 'Visit not found' });
        }

        visit.visitReason = visitReason;
        visit.observations = observations;
        visit.diagnosis = diagnosis;
        visit.recommendations = recommendations;
        visit.animal = animal;
        visit.treatment = treatment;
        visit.treatmentQuantity = treatmentQuantity;
        visit.procedures = procedures;
        visit.client = client;
        visit.clientId = client.id; // Extract clientId from the client object
        visit.isDeleted = false;
        visit.updatedBy = updatedBy; // Handle updatedBy field

        await visit.save();

        res.status(200).json(visit);
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

// Soft delete an existing visit
const softDeleteVisit = async (req, res) => {
    const { visitId } = req.params;

    try {
        const visit = await Visit.findByPk(visitId);
        if (!visit) {
            return res.status(404).json({ message: 'Visit not found' });
        }

        visit.isDeleted = true;
        await visit.save();

        res.status(200).json({ message: 'Visit soft deleted' });
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

// Final delete an existing visit
const finalDeleteVisit = async (req, res) => {
    const { visitId } = req.params;

    try {
        const visit = await Visit.findByPk(visitId);
        if (!visit) {
            return res.status(404).json({ message: 'Visit not found' });
        }

        await visit.destroy();

        res.status(200).send();
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

module.exports = { createVisit, getVisitsByClientId, updateVisit, softDeleteVisit, finalDeleteVisit };