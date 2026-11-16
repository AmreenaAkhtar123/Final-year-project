
import mongoose from 'mongoose';

const emergencyContactSchema = new mongoose.Schema(
  {
    // The student who owns this emergency contact.
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },

    name: {
      type: String,
      required: true,
      trim: true,
      minlength: 2,
      maxlength: 50,
    },

    relationship: {
      type: String,
      required: true,
      trim: true,
      maxlength: 40,
    },

    phoneNumber: {
      type: String,
      required: true,
      trim: true,
      maxlength: 20,
    },

    // A contact must explicitly consent before being used for SOS.
    consentGiven: {
      type: Boolean,
      required: true,
      default: false,
    },

    // Records when consent was confirmed.
    consentAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

const EmergencyContact = mongoose.model(
  'EmergencyContact',
  emergencyContactSchema
);

export default EmergencyContact;
