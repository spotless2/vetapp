const { Appointment, Cabinet, User } = require('../models');
const { Op } = require('sequelize');

// Create a new appointment
const createAppointment = async (req, res) => {
    console.log('📝 CREATE APPOINTMENT - Request received:', {
        body: req.body,
        headers: req.headers['content-type']
    });

    const { title, startTime, endTime, type, status, clientName, clientPhone, clientEmail, reason, notes, cabinetId, createdBy } = req.body;

    // Validate required fields
    if (!title || !startTime || !endTime || !cabinetId) {
        console.error('❌ CREATE APPOINTMENT - Missing required fields:', {
            title: !!title,
            startTime: !!startTime,
            endTime: !!endTime,
            cabinetId: !!cabinetId
        });
        return res.status(400).json({ 
            message: 'Câmpurile obligatorii lipsesc',
            missing: {
                title: !title,
                startTime: !startTime,
                endTime: !endTime,
                cabinetId: !cabinetId
            }
        });
    }

    try {
        console.log('🔍 Checking for overlapping appointments...');
        // Check for overlapping appointments in the same cabinet
        const overlapping = await Appointment.findOne({
            where: {
                cabinetId,
                [Op.or]: [
                    {
                        startTime: {
                            [Op.between]: [startTime, endTime]
                        }
                    },
                    {
                        endTime: {
                            [Op.between]: [startTime, endTime]
                        }
                    },
                    {
                        [Op.and]: [
                            { startTime: { [Op.lte]: startTime } },
                            { endTime: { [Op.gte]: endTime } }
                        ]
                    }
                ]
            }
        });

        if (overlapping) {
            console.warn('⚠️ CREATE APPOINTMENT - Overlapping appointment found:', overlapping.id);
            return res.status(400).json({ message: 'Există deja o programare în acest interval orar' });
        }

        console.log('✅ No overlapping appointments, creating new appointment...');
        const newAppointment = await Appointment.create({
            title,
            startTime,
            endTime,
            type: type || 'appointment',
            status: status || 'scheduled',
            clientName,
            clientPhone,
            clientEmail,
            reason,
            notes,
            cabinetId,
            createdBy
        });

        console.log('✅ CREATE APPOINTMENT - Success:', {
            id: newAppointment.id,
            title: newAppointment.title,
            type: newAppointment.type
        });
        res.status(201).json(newAppointment);
    } catch (err) {
        console.error('❌ CREATE APPOINTMENT - Error:', {
            message: err.message,
            stack: err.stack,
            name: err.name
        });
        res.status(500).json({ 
            message: 'Eroare la crearea programării', 
            error: err.message,
            details: process.env.NODE_ENV === 'development' ? err.stack : undefined
        });
    }
};

// Get all appointments for a cabinet
const getAppointmentsByCabinet = async (req, res) => {
    console.log('📋 GET APPOINTMENTS BY CABINET - Request:', {
        cabinetId: req.params.cabinetId,
        query: req.query
    });

    const { cabinetId } = req.params;
    const { startDate, endDate, type } = req.query;

    try {
        const whereClause = { cabinetId };

        // Filter by date range if provided
        if (startDate && endDate) {
            whereClause.startTime = {
                [Op.between]: [startDate, endDate]
            };
        }

        // Filter by type if provided
        if (type) {
            whereClause.type = type;
        }

        const appointments = await Appointment.findAll({
            where: whereClause,
            include: [
                {
                    model: User,
                    as: 'creator',
                    attributes: ['id', 'username', 'firstName', 'lastName']
                }
            ],
            order: [['startTime', 'ASC']]
        });

        console.log(`✅ GET APPOINTMENTS BY CABINET - Found ${appointments.length} appointments`);
        res.status(200).json(appointments);
    } catch (err) {
        console.error('❌ GET APPOINTMENTS BY CABINET - Error:', err.message);
        res.status(500).json({ message: 'Eroare la încărcarea programărilor', error: err.message });
    }
};

// Get a single appointment by ID
const getAppointmentById = async (req, res) => {
    const { appointmentId } = req.params;

    try {
        const appointment = await Appointment.findByPk(appointmentId, {
            include: [
                {
                    model: User,
                    as: 'creator',
                    attributes: ['id', 'username', 'firstName', 'lastName']
                },
                {
                    model: User,
                    as: 'updater',
                    attributes: ['id', 'username', 'firstName', 'lastName']
                },
                {
                    model: Cabinet,
                    attributes: ['id', 'name', 'address']
                }
            ]
        });

        if (!appointment) {
            return res.status(404).json({ message: 'Programarea nu a fost găsită' });
        }

        res.status(200).json(appointment);
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

// Update an appointment
const updateAppointment = async (req, res) => {
    console.log('🔄 UPDATE APPOINTMENT - Request:', {
        appointmentId: req.params.appointmentId,
        body: req.body
    });

    const { appointmentId } = req.params;
    const { title, startTime, endTime, type, status, clientName, clientPhone, clientEmail, reason, notes, updatedBy } = req.body;

    try {
        const appointment = await Appointment.findByPk(appointmentId);

        if (!appointment) {
            return res.status(404).json({ message: 'Programarea nu a fost găsită' });
        }

        // Check for overlapping appointments (excluding current one)
        if (startTime && endTime) {
            const overlapping = await Appointment.findOne({
                where: {
                    id: { [Op.ne]: appointmentId },
                    cabinetId: appointment.cabinetId,
                    [Op.or]: [
                        {
                            startTime: {
                                [Op.between]: [startTime, endTime]
                            }
                        },
                        {
                            endTime: {
                                [Op.between]: [startTime, endTime]
                            }
                        },
                        {
                            [Op.and]: [
                                { startTime: { [Op.lte]: startTime } },
                                { endTime: { [Op.gte]: endTime } }
                            ]
                        }
                    ]
                }
            });

            if (overlapping) {
                return res.status(400).json({ message: 'Există deja o programare în acest interval orar' });
            }
        }

        await appointment.update({
            title: title || appointment.title,
            startTime: startTime || appointment.startTime,
            endTime: endTime || appointment.endTime,
            type: type || appointment.type,
            status: status || appointment.status,
            clientName: clientName !== undefined ? clientName : appointment.clientName,
            clientPhone: clientPhone !== undefined ? clientPhone : appointment.clientPhone,
            clientEmail: clientEmail !== undefined ? clientEmail : appointment.clientEmail,
            reason: reason !== undefined ? reason : appointment.reason,
            notes: notes !== undefined ? notes : appointment.notes,
            updatedBy: updatedBy || appointment.updatedBy
        });

        console.log('✅ UPDATE APPOINTMENT - Success:', appointmentId);
        res.status(200).json(appointment);
    } catch (err) {
        console.error('❌ UPDATE APPOINTMENT - Error:', err.message);
        res.status(500).json({ message: 'Eroare la actualizarea programării', error: err.message });
    }
};

// Delete an appointment
const deleteAppointment = async (req, res) => {
    console.log('🗑️ DELETE APPOINTMENT - Request:', req.params.appointmentId);

    const { appointmentId } = req.params;

    try {
        const appointment = await Appointment.findByPk(appointmentId);

        if (!appointment) {
            return res.status(404).json({ message: 'Programarea nu a fost găsită' });
        }

        await appointment.destroy();
        console.log('✅ DELETE APPOINTMENT - Success:', appointmentId);
        res.status(200).json({ message: 'Programarea a fost ștearsă cu succes' });
    } catch (err) {
        console.error('❌ DELETE APPOINTMENT - Error:', err.message);
        res.status(500).json({ message: 'Eroare la ștergerea programării', error: err.message });
    }
};

// Get today's appointments for a cabinet
const getTodayAppointments = async (req, res) => {
    const { cabinetId } = req.params;

    try {
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const tomorrow = new Date(today);
        tomorrow.setDate(tomorrow.getDate() + 1);

        const appointments = await Appointment.findAll({
            where: {
                cabinetId,
                startTime: {
                    [Op.gte]: today,
                    [Op.lt]: tomorrow
                }
            },
            include: [
                {
                    model: User,
                    as: 'creator',
                    attributes: ['id', 'username', 'firstName', 'lastName']
                }
            ],
            order: [['startTime', 'ASC']]
        });

        res.status(200).json(appointments);
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

module.exports = {
    createAppointment,
    getAppointmentsByCabinet,
    getAppointmentById,
    updateAppointment,
    deleteAppointment,
    getTodayAppointments
};
