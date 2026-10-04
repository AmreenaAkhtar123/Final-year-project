import mongoose from 'mongoose';

const moodTrackerSchema = new mongoose.Schema(
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

    factors: {
      type: [String],
      default: [],
    },

    note: {
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

const MoodTracker = mongoose.model(
  'MoodTracker',
  moodTrackerSchema
);

export default MoodTracker;