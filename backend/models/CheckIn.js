import mongoose from 'mongoose';

const checkInSchema = new mongoose.Schema(
  {
    email: {
      type: String,
      required: true,
      lowercase: true,
      trim: true,
    },

    mood: {
      type: String,
      required: true,
      enum: [
        'Low',
        'Okay',
        'Neutral',
        'Good',
        'Great',
      ],
    },

    moodIntensity: {
      type: Number,
      required: true,
      min: 1,
      max: 10,
    },

    emotions: {
      type: [String],
      default: [],
    },

    energyLevel: {
      type: Number,
      required: true,
      min: 1,
      max: 10,
    },

    sleepQuality: {
      type: Number,
      required: true,
      min: 1,
      max: 10,
    },

    factors: {
      type: [String],
      default: [],
    },

    reflection: {
      type: String,
      default: '',
      trim: true,
      maxlength: 500,
    },
  },
  {
    timestamps: true,
  }
);

const CheckIn = mongoose.model('CheckIn', checkInSchema);

export default CheckIn;