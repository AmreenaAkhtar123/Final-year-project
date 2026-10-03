import mongoose from 'mongoose';

const studentWellbeingSchema = new mongoose.Schema(
  {
    email: {
      type: String,
      required: true,
      lowercase: true,
      trim: true,
    },

    dealingWith: {
      type: [String],
      default: [],
    },

    effects: {
      type: [String],
      default: [],
    },

    pressureSources: {
      type: [String],
      default: [],
    },

    somethingElse: {
      type: String,
      default: '',
      trim: true,
      maxlength: 500,
    },

    // Core wellbeing metrics
    studentPulse: {
      type: Number,
      min: 0,
      max: 100,
    },

    pressureIndex: {
      type: Number,
      min: 0,
      max: 100,
    },

    focusReadiness: {
      type: Number,
      min: 0,
      max: 100,
    },

    recoveryIndex: {
      type: Number,
      min: 0,
      max: 100,
    },

    overloadIndex: {
      type: Number,
      min: 0,
      max: 100,
    },

    // Wellbeing indicators
    stress: {
      type: Number,
      min: 0,
      max: 10,
    },

    examPressure: {
      type: Number,
      min: 0,
      max: 10,
    },

    burnout: {
      type: Number,
      min: 0,
      max: 10,
    },

    sleep: {
      type: Number,
      min: 0,
      max: 10,
    },

    energy: {
      type: Number,
      min: 0,
      max: 10,
    },

    workload: {
      type: Number,
      min: 0,
      max: 10,
    },

    socialConnection: {
      type: Number,
      min: 0,
      max: 10,
    },

    motivation: {
      type: Number,
      min: 0,
      max: 10,
    },

    // Wellbeing areas
    academicHealth: {
      type: Number,
      min: 0,
      max: 10,
    },

    mentalHealth: {
      type: Number,
      min: 0,
      max: 10,
    },

    lifestyleHealth: {
      type: Number,
      min: 0,
      max: 10,
    },

    // Current monitor state
    monitorStatus: {
      type: String,
      default: '',
      trim: true,
    },

    primarySignal: {
      type: String,
      default: '',
      trim: true,
    },

    aiInsight: {
      type: String,
      default: '',
      trim: true,
      maxlength: 2000,
    },
  },
  {
    timestamps: true,
  }
);

const StudentWellbeing = mongoose.model(
  'StudentWellbeing',
  studentWellbeingSchema
);

export default StudentWellbeing;
