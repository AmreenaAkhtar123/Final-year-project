
import mongoose from 'mongoose';

const assessmentResultSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },

    assessmentType: {
      type: String,
      required: true,
      enum: [
        'anxiety_stress',
        'depression_mood',
        'student_wellbeing',
        'general_wellbeing',
      ],
    },

    answers: {
      type: [Number],
      required: true,
      validate: {
        validator: (answers) =>
          Array.isArray(answers) &&
          answers.length === 20 &&
          answers.every(
            (answer) =>
              Number.isInteger(answer) &&
              answer >= 0 &&
              answer <= 3,
          ),
        message: 'Exactly 20 valid answers are required. Each answer must be between 0 and 3.',
      },
    },

    totalScore: {
      type: Number,
      required: true,
      min: 0,
      max: 60,
    },

    resultLevel: {
      type: String,
      required: true,
      trim: true,
    },
  },
  {
    timestamps: true,
  },
);

const AssessmentResult = mongoose.model(
  'AssessmentResult',
  assessmentResultSchema,
);

export default AssessmentResult;
