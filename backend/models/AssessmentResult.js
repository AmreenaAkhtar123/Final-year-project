
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
        'phq9',
        'gad7',
        'who5',
      ],
    },

    answers: {
      type: [Number],
      required: true,
      validate: {
        validator: function (answers) {
          const rules = {
            anxiety_stress: { count: 20, max: 3 },
            depression_mood: { count: 20, max: 3 },
            student_wellbeing: { count: 20, max: 3 },
            general_wellbeing: { count: 20, max: 3 },
            phq9: { count: 9, max: 3 },
            gad7: { count: 7, max: 3 },
            who5: { count: 5, max: 5 },
          };

          const rule = rules[this.assessmentType];

          return (
            rule !== undefined &&
            Array.isArray(answers) &&
            answers.length === rule.count &&
            answers.every(
              (answer) =>
                Number.isInteger(answer) &&
                answer >= 0 &&
                answer <= rule.max,
            )
          );
        },
        message: 'Invalid answers or answer count for this assessment.',
      },
    },

    totalScore: {
      type: Number,
      required: true,
      min: 0,
      validate: {
        validator: function (score) {
          const maximumScores = {
            anxiety_stress: 60,
            depression_mood: 60,
            student_wellbeing: 60,
            general_wellbeing: 60,
            phq9: 27,
            gad7: 21,
            who5: 25,
          };

          const maximum = maximumScores[this.assessmentType];

          return (
            maximum !== undefined &&
            Number.isInteger(score) &&
            score <= maximum
          );
        },
        message: 'Invalid total score for this assessment.',
      },
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
