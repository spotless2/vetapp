const { Pet } = require('../models');

// Create a new pet
const createPet = async (req, res) => {
    const { name, species, breed, gender, birthDate, color, reproductiveStatus, photo, allergies, distinctiveMarks, animalCardNumber, insuranceNumber, bloodGroup, microchipCode, passportSeries, description, healthPlan, patientAlerts, internalNotes, clientId } = req.body;

    try {
        const newPet = await Pet.create({
            name,
            species,
            breed,
            gender,
            birthDate,
            color,
            reproductiveStatus,
            photo,
            allergies,
            distinctiveMarks,
            animalCardNumber,
            insuranceNumber,
            bloodGroup,
            microchipCode,
            passportSeries,
            description,
            healthPlan,
            patientAlerts,
            internalNotes,
            clientId
        });

        res.status(201).json(newPet);
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

// Fetch pets by clientId
const getPetsByClientId = async (req, res) => {
    const { clientId } = req.params;

    try {
        const pets = await Pet.findAll({ where: { clientId } });
        res.status(200).json(pets);
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

const updatePet = async (req, res) => {
    const { petId } = req.params;
    const { name, species, breed, gender, birthDate, color, reproductiveStatus, photo, allergies, distinctiveMarks, animalCardNumber, insuranceNumber, bloodGroup, microchipCode, passportSeries, description, healthPlan, patientAlerts, internalNotes, clientId } = req.body;

    try {
        const pet = await Pet.findByPk(petId);
        if (!pet) {
            return res.status(404).json({ message: 'Pet not found' });
        }

        pet.name = name;
        pet.species = species;
        pet.breed = breed;
        pet.gender = gender;
        pet.birthDate = birthDate;
        pet.color = color;
        pet.reproductiveStatus = reproductiveStatus;
        pet.photo = photo;
        pet.allergies = allergies;
        pet.distinctiveMarks = distinctiveMarks;
        pet.animalCardNumber = animalCardNumber;
        pet.insuranceNumber = insuranceNumber;
        pet.bloodGroup = bloodGroup;
        pet.microchipCode = microchipCode;
        pet.passportSeries = passportSeries;
        pet.description = description;
        pet.healthPlan = healthPlan;
        pet.patientAlerts = patientAlerts;
        pet.internalNotes = internalNotes;
        pet.clientId = clientId;

        await pet.save();

        res.status(200).json(pet);
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

const deletePet = async (req, res) => {
    const { petId } = req.params;

    try {
        const pet = await Pet.findByPk(petId);
        if (!pet) {
            return res.status(404).json({ message: 'Pet not found' });
        }

        await pet.destroy();

        res.status(200).send();
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.message });
    }
};

module.exports = { createPet, getPetsByClientId, updatePet, deletePet };