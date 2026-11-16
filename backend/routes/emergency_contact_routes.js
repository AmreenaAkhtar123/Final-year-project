
import express from 'express';

import EmergencyContact from '../models/EmergencyContact.js';
import authMiddleware from '../middleware/auth_middleware.js';

const router = express.Router();

// Validate contact details.
const validateContact = (name, relationship, phoneNumber) => {
  if (
    typeof name !== 'string' ||
    name.trim().length < 2 ||
    name.trim().length > 50
  ) {
    return 'Name must contain between 2 and 50 characters.';
  }

  if (
    typeof relationship !== 'string' ||
    relationship.trim().length < 2 ||
    relationship.trim().length > 40
  ) {
    return 'Please provide a valid relationship.';
  }

  if (
    typeof phoneNumber !== 'string' ||
    !/^\+?[0-9\s()-]{7,20}$/.test(phoneNumber.trim())
  ) {
    return 'Please provide a valid phone number.';
  }

  return null;
};

// =====================================================
// ADD EMERGENCY CONTACT
// =====================================================

router.post(
  '/api/emergency-contacts',
  authMiddleware,
  async (req, res) => {
    try {
      const {
        name,
        relationship,
        phoneNumber,
        consentGiven,
      } = req.body;

      const validationError = validateContact(
        name,
        relationship,
        phoneNumber,
      );

      if (validationError) {
        return res.status(400).json({
          message: validationError,
        });
      }

      if (typeof consentGiven !== 'boolean') {
        return res.status(400).json({
          message: 'Please specify whether the contact has given consent.',
        });
      }

      const contact = await EmergencyContact.create({
        userId: req.user.userId,
        name: name.trim(),
        relationship: relationship.trim(),
        phoneNumber: phoneNumber.trim(),
        consentGiven,
        consentAt: consentGiven ? new Date() : null,
      });

      return res.status(201).json({
        message: consentGiven
          ? 'Emergency contact added with consent.'
          : 'Emergency contact added but is not active for SOS until consent is given.',
        contact,
      });
    } catch (error) {
      console.error('Add emergency contact error:', error);

      return res.status(500).json({
        message: 'Failed to add emergency contact.',
      });
    }
  },
);

// =====================================================
// GET LOGGED-IN USER'S EMERGENCY CONTACTS
// =====================================================

router.get(
  '/api/emergency-contacts',
  authMiddleware,
  async (req, res) => {
    try {
      const contacts = await EmergencyContact.find({
        userId: req.user.userId,
      }).sort({ createdAt: -1 });

      return res.status(200).json({
        message: 'Emergency contacts retrieved successfully.',
        contacts,
      });
    } catch (error) {
      console.error('Get emergency contacts error:', error);

      return res.status(500).json({
        message: 'Failed to retrieve emergency contacts.',
      });
    }
  },
);

// =====================================================
// UPDATE EMERGENCY CONTACT
// =====================================================

router.put(
  '/api/emergency-contacts/:id',
  authMiddleware,
  async (req, res) => {
    try {
      const {
        name,
        relationship,
        phoneNumber,
        consentGiven,
      } = req.body;

      const contact = await EmergencyContact.findOne({
        _id: req.params.id,
        userId: req.user.userId,
      });

      if (!contact) {
        return res.status(404).json({
          message: 'Emergency contact not found.',
        });
      }

      const updatedName = name ?? contact.name;
      const updatedRelationship = relationship ?? contact.relationship;
      const updatedPhoneNumber = phoneNumber ?? contact.phoneNumber;

      const validationError = validateContact(
        updatedName,
        updatedRelationship,
        updatedPhoneNumber,
      );

      if (validationError) {
        return res.status(400).json({
          message: validationError,
        });
      }

      if (
        consentGiven !== undefined &&
        typeof consentGiven !== 'boolean'
      ) {
        return res.status(400).json({
          message: 'Consent must be true or false.',
        });
      }

      contact.name = updatedName.trim();
      contact.relationship = updatedRelationship.trim();
      contact.phoneNumber = updatedPhoneNumber.trim();

      if (consentGiven === true && contact.consentGiven !== true) {
        contact.consentGiven = true;
        contact.consentAt = new Date();
      } else if (consentGiven === false) {
        contact.consentGiven = false;
        contact.consentAt = null;
      }

      await contact.save();

      return res.status(200).json({
        message: 'Emergency contact updated successfully.',
        contact,
      });
    } catch (error) {
      console.error('Update emergency contact error:', error);

      return res.status(500).json({
        message: 'Failed to update emergency contact.',
      });
    }
  },
);

// =====================================================
// DELETE EMERGENCY CONTACT
// =====================================================

router.delete(
  '/api/emergency-contacts/:id',
  authMiddleware,
  async (req, res) => {
    try {
      const contact = await EmergencyContact.findOneAndDelete({
        _id: req.params.id,
        userId: req.user.userId,
      });

      if (!contact) {
        return res.status(404).json({
          message: 'Emergency contact not found.',
        });
      }

      return res.status(200).json({
        message: 'Emergency contact removed successfully.',
      });
    } catch (error) {
      console.error('Delete emergency contact error:', error);

      return res.status(500).json({
        message: 'Failed to remove emergency contact.',
      });
    }
  },
);

export default router;
