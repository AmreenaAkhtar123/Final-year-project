
import express from 'express';
import AssessmentResult from '../models/AssessmentResult.js';
import authMiddleware from '../middleware/auth_middleware.js';

const router = express.Router();

const assessmentRules = {
  anxiety_stress: { count: 20, maxAnswer: 3 },
  depression_mood: { count: 20, maxAnswer: 3 },
  student_wellbeing: { count: 20, maxAnswer: 3 },
  general_wellbeing: { count: 20, maxAnswer: 3 },
  phq9: { count: 9, maxAnswer: 3 },
  gad7: { count: 7, maxAnswer: 3 },
  who5: { count: 5, maxAnswer: 5 },
};

const assessmentTypes = Object.keys(assessmentRules);

// Calculate the interpretation for each assessment.
const calculateResultLevel = (assessmentType, score) => {
  // Existing custom assessments: keep their original thresholds.
  if (assessmentType === 'general_wellbeing') {
    if (score <= 15) return 'Needs Attention';
    if (score <= 30) return 'Developing';
    if (score <= 45) return 'Good';
    return 'Positive';
  }

  if (
    assessmentType === 'anxiety_stress' ||
    assessmentType === 'depression_mood' ||
    assessmentType === 'student_wellbeing'
  ) {
    if (score <= 10) return 'Low';
    if (score <= 20) return 'Mild';
    if (score <= 30) return 'Moderate';
    return 'Higher';
  }

  // PHQ-9: score range 0–27.
  if (assessmentType === 'phq9') {
    if (score <= 4) return 'Minimal';
    if (score <= 9) return 'Mild';
    if (score <= 14) return 'Moderate';
    if (score <= 19) return 'Moderately Severe';
    return 'Severe';
  }

  // GAD-7: score range 0–21.
  if (assessmentType === 'gad7') {
    if (score <= 4) return 'Minimal';
    if (score <= 9) return 'Mild';
    if (score <= 14) return 'Moderate';
    return 'Severe';
  }

  // WHO-5: raw score 0–25, converted to a percentage.
  if (assessmentType === 'who5') {
    const percentageScore = score * 4;

    if (percentageScore < 50) {
      return 'Poor Wellbeing';
    }

    return 'Adequate Wellbeing';
  }

  return 'Unknown';
}

// Save a completed assessment.
router.post('/api/assessments', authMiddleware, async (req, res) => {
  try {
    const { assessmentType, answers } = req.body;

    const rule = assessmentRules[assessmentType];

    if (!rule) {
      return res.status(400).json({
        message: 'Invalid assessment type.',
      });
    }

    if (
      !Array.isArray(answers) ||
      answers.length !== rule.count ||
      !answers.every(
        (answer) =>
          Number.isInteger(answer) &&
          answer >= 0 &&
          answer <= rule.maxAnswer,
      )
    ) {
      return res.status(400).json({
        message: `Exactly ${rule.count} valid answers are required. Each answer must be between 0 and ${rule.maxAnswer}.`,
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
      ...(assessmentType === 'who5'
        ? { percentageScore: totalScore * 4 }
        : {}),
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
      assessments: assessments.map((assessment) => {
        const result = assessment.toObject();

        if (result.assessmentType === 'who5') {
          result.percentageScore = result.totalScore * 4;
        }

        return result;
      }),
    });
  } catch (error) {
    console.error('Get assessment history error:', error);

    return res.status(500).json({
      message: 'Failed to retrieve assessment history.',
    });
  }
});

export default router;
