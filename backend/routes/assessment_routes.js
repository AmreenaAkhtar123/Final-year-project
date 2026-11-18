
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
  // Existing custom assessments.
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
};

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

// FR-14: Analyze assessment scores and historical trends.
router.get(
  '/api/assessments/predictive-risk',
  authMiddleware,
  async (req, res) => {
    try {
      const supportedTypes = ['phq9', 'gad7', 'who5'];

      // Retrieve only this authenticated user's validated assessment records.
      const history = await AssessmentResult.find({
        userId: req.user.userId,
        assessmentType: { $in: supportedTypes },
      })
        .sort({ createdAt: -1 })
        .lean();

      // Keep the latest two records for each assessment type.
      const groupedHistory = {
        phq9: [],
        gad7: [],
        who5: [],
      };

      for (const record of history) {
        const type = record.assessmentType;

        if (
          supportedTypes.includes(type) &&
          groupedHistory[type].length < 2
        ) {
          groupedHistory[type].push(record);
        }
      }

      // Compare the latest result with the previous result.
      const analyzeTrend = (assessmentType) => {
        const records = groupedHistory[assessmentType];

        if (records.length === 0) {
          return {
            available: false,
            trend: 'not_available',
            latestScore: null,
            previousScore: null,
          };
        }

        const latest = records[0];
        const previous = records[1] || null;

        const latestScore =
          assessmentType === 'who5'
            ? latest.totalScore * 4
            : latest.totalScore;

        const previousScore = previous
          ? assessmentType === 'who5'
            ? previous.totalScore * 4
            : previous.totalScore
          : null;

        let trend = 'not_available';

        if (previous) {
          if (assessmentType === 'who5') {
            if (latestScore < previousScore) {
              trend = 'worsening';
            } else if (latestScore > previousScore) {
              trend = 'improving';
            } else {
              trend = 'stable';
            }
          } else {
            if (latestScore > previousScore) {
              trend = 'worsening';
            } else if (latestScore < previousScore) {
              trend = 'improving';
            } else {
              trend = 'stable';
            }
          }
        }

        return {
          available: true,
          trend,
          latestScore,
          previousScore,
          latestDate: latest.createdAt,
          previousDate: previous?.createdAt || null,
        };
      };

      const phq9 = analyzeTrend('phq9');
      const gad7 = analyzeTrend('gad7');
      const who5 = analyzeTrend('who5');

      const missingAssessments = [];

      if (!phq9.available) missingAssessments.push('PHQ-9');
      if (!gad7.available) missingAssessments.push('GAD-7');
      if (!who5.available) missingAssessments.push('WHO-5');

      const worseningTrend = [
        phq9,
        gad7,
        who5,
      ].some((result) => result.trend === 'worsening');

      // A positive PHQ-9 question 9 response is flagged separately.
      const latestPhq9 = groupedHistory.phq9[0];

      const safetyFollowUpRequired =
        latestPhq9 &&
        Array.isArray(latestPhq9.answers) &&
        latestPhq9.answers[8] > 0;

      let concernLevel;
      let recommendations = [];

      // High concern has priority over other conditions.
      if (
        (phq9.available && phq9.latestScore >= 15) ||
        (gad7.available && gad7.latestScore >= 15)
      ) {
        concernLevel = 'High';

        recommendations = [
          'Consider seeking support from a qualified mental health professional.',
          'Discuss your assessment results with a healthcare professional.',
          'Reach out to someone you trust for emotional support.',
        ];
      } else if (
        missingAssessments.length > 0
      ) {
        // Do not classify incomplete assessment data as Low concern.
        concernLevel = 'insufficient_data';

        recommendations = [
          'Complete the missing validated assessments to receive a more complete analysis.',
          'Continue monitoring your wellbeing through MindMate.',
        ];
      } else if (
        (phq9.latestScore >= 10 && phq9.latestScore <= 14) ||
        (gad7.latestScore >= 10 && gad7.latestScore <= 14) ||
        who5.latestScore < 50 ||
        worseningTrend
      ) {
        concernLevel = 'Moderate';

        recommendations = [
          'Consider speaking with a qualified mental health professional or counsellor.',
          'Continue monitoring changes in your assessment results.',
          'Maintain supportive daily routines and reach out to trusted people.',
        ];
      } else {
        // Low concern requires all three results and no detected worsening.
        concernLevel = 'Low';

        recommendations = [
          'Continue maintaining healthy daily routines.',
          'Keep monitoring your emotional wellbeing.',
          'Continue using MindMate wellbeing activities and support tools.',
        ];
      }

      if (safetyFollowUpRequired) {
        recommendations.unshift(
          'Your PHQ-9 response indicates that additional safety support is important. Please seek support promptly from a qualified professional or trusted person. If you may be in immediate danger, contact local emergency services.',
        );
      }

      return res.status(200).json({
        message: 'Assessment risk analysis completed successfully.',

        analysis: {
          concernLevel,

          isDiagnosis: false,

          explanation:
            'This is a rule-based wellbeing analysis using assessment scores and historical trends. It is not a medical diagnosis.',

          assessments: {
            phq9,
            gad7,
            who5,
          },

          trendAnalysis: {
            worseningTrend,
          },

          missingAssessments,

          safetyFollowUpRequired: Boolean(
            safetyFollowUpRequired,
          ),

          recommendations,
        },
      });
    } catch (error) {
      console.error('Predictive risk analysis error:', error);

      return res.status(500).json({
        message: 'Failed to perform assessment risk analysis.',
      });
    }
  },
);

export default router;
