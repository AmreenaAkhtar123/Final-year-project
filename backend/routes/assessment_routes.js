
import express from 'express';
import AssessmentResult from '../models/AssessmentResult.js';
import authMiddleware from '../middleware/auth_middleware.js';

const router = express.Router();

const assessmentTypes = [
  'anxiety_stress',
  'depression_mood',
  'student_wellbeing',
  'general_wellbeing',
];

// Calculate the result category using each screen's existing thresholds.
const calculateResultLevel = (assessmentType, score) => {
  if (assessmentType === 'general_wellbeing') {
    if (score <= 15) return 'Needs Attention';
    if (score <= 30) return 'Developing';
    if (score <= 45) return 'Good';
    return 'Positive';
  }

  if (score <= 10) return 'Low';
  if (score <= 20) return 'Mild';
  if (score <= 30) return 'Moderate';
  return 'Higher';
};

// Save a completed assessment.
router.post('/api/assessments', authMiddleware, async (req, res) => {
  try {
    const { assessmentType, answers } = req.body;

    if (!assessmentTypes.includes(assessmentType)) {
      return res.status(400).json({
        message: 'Invalid assessment type.',
      });
    }

    if (
      !Array.isArray(answers) ||
      answers.length !== 20 ||
      !answers.every(
        (answer) =>
          Number.isInteger(answer) &&
          answer >= 0 &&
          answer <= 3,
      )
    ) {
      return res.status(400).json({
        message: 'Exactly 20 valid answers are required. Each answer must be between 0 and 3.',
      });
    }

    const totalScore = answers.reduce(
      (total, answer) => total + answer,
      0,
    );

    const resultLevel = calculateResultLevel(
      assessmentType,
      totalScore,
    );

    const assessment = await AssessmentResult.create({
      userId: req.user.userId,
      assessmentType,
      answers,
      totalScore,
      resultLevel,
    });

    return res.status(201).json({
      message: 'Assessment result saved successfully.',
      assessment,
    });
  } catch (error) {
    console.error('Save assessment error:', error);

    return res.status(500).json({
      message: 'Failed to save assessment result.',
    });
  }
});

// Retrieve the authenticated user's assessment history.
router.get('/api/assessments', authMiddleware, async (req, res) => {
  try {
    const { assessmentType } = req.query;

    if (
      assessmentType &&
      !assessmentTypes.includes(assessmentType)
    ) {
      return res.status(400).json({
        message: 'Invalid assessment type.',
      });
    }

    const filter = {
      userId: req.user.userId,
    };

    if (assessmentType) {
      filter.assessmentType = assessmentType;
    }

    const assessments = await AssessmentResult.find(filter)
      .sort({ createdAt: -1 });

    return res.status(200).json({
      message: 'Assessment history retrieved successfully.',
      assessments,
    });
  } catch (error) {
    console.error('Get assessment history error:', error);

    return res.status(500).json({
      message: 'Failed to retrieve assessment history.',
    });
  }
});

export default router;
