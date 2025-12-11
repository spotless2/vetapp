const express = require('express');
const {
    createAppointment,
    getAppointmentsByCabinet,
    getAppointmentById,
    updateAppointment,
    deleteAppointment,
    getTodayAppointments
} = require('../controllers/appointmentController');

const router = express.Router();

// Create a new appointment
router.post('/', createAppointment);

// Get all appointments for a cabinet (with optional filters)
router.get('/cabinet/:cabinetId', getAppointmentsByCabinet);

// Get today's appointments for a cabinet
router.get('/cabinet/:cabinetId/today', getTodayAppointments);

// Get a single appointment by ID
router.get('/:appointmentId', getAppointmentById);

// Update an appointment
router.put('/:appointmentId', updateAppointment);

// Delete an appointment
router.delete('/:appointmentId', deleteAppointment);

module.exports = router;
