import express from 'express';
import User from '../models/User.js';
import StudentWellbeing from '../models/StudentWellbeing.js';

const router = express.Router();

router.post('/api/student-wellbeing', async (req, res) => {
  try {
    const {
      email,

      dealingWith,
      effects,
      pressureSources,
      somethingElse,

      studentPulse,
      pressureIndex,
      focusReadiness,
      recoveryIndex,
      overloadIndex,

      stress,
      examPressure,
      burnout,
      sleep,
      energy,
      workload,
      socialConnection,
      motivation,

      academicHealth,
      mentalHealth,
      lifestyleHealth,

      monitorStatus,
      primarySignal,
      aiInsight,
    } = req.body;

    // --------------------------------
    // REQUIRED EMAIL
    // --------------------------------

    if (!email) {
      return res.status(400).json({
        message: 'Email is required.',
      });
    }

    const normalizedEmail = email
      .toLowerCase()
      .trim();

    // --------------------------------
    // MAKE SURE USER EXISTS
    // --------------------------------

    const user = await User.findOne({
      email: normalizedEmail,
    });

    if (!user) {
      return res.status(404).json({
        message: 'User not found.',
      });
    }

    // --------------------------------
    // SAVE SNAPSHOT
    // --------------------------------

    const wellbeing = await StudentWellbeing.create({
      email: user.email,

      dealingWith: Array.isArray(dealingWith)
        ? dealingWith
        : [],

      effects: Array.isArray(effects)
        ? effects
        : [],

      pressureSources: Array.isArray(
        pressureSources
      )
        ? pressureSources
        : [],

      somethingElse:
        typeof somethingElse === 'string'
          ? somethingElse.trim()
          : '',

      studentPulse,
      pressureIndex,
      focusReadiness,
      recoveryIndex,
      overloadIndex,

      stress,
      examPressure,
      burnout,
      sleep,
      energy,
      workload,
      socialConnection,
      motivation,

      academicHealth,
      mentalHealth,
      lifestyleHealth,

      monitorStatus:
        typeof monitorStatus === 'string'
          ? monitorStatus
          : '',

      primarySignal:
        typeof primarySignal === 'string'
          ? primarySignal
          : '',

      aiInsight:
        typeof aiInsight === 'string'
          ? aiInsight.trim()
          : '',
    });

    console.log(
      'Student wellbeing snapshot saved:',
      wellbeing._id
    );

    return res.status(201).json({
      message:
        'Student wellbeing saved successfully.',
      wellbeing,
    });
  } catch (error) {
    console.error(
      'Save student wellbeing error:',
      error
    );

    return res.status(500).json({
      message:
        'Failed to save student wellbeing.',
    });
  }
});

router.get('/api/student-wellbeing/latest', async (req, res) => {
  try {
    const { email } = req.query;

    if (!email) {
      return res.status(400).json({
        message: 'Email is required.',
      });
    }

    const normalizedEmail = email
      .toLowerCase()
      .trim();

    // Make sure the user exists
    const user = await User.findOne({
      email: normalizedEmail,
    });

    if (!user) {
      return res.status(404).json({
        message: 'User not found.',
      });
    }

    // Get most recent wellbeing snapshot
    const wellbeing =
      await StudentWellbeing.findOne({
        email: normalizedEmail,
      }).sort({
        createdAt: -1,
      });

    if (!wellbeing) {
      return res.status(404).json({
        message:
          'No student wellbeing data found.',
      });
    }

    return res.status(200).json({
      message:
        'Latest student wellbeing retrieved successfully.',
      wellbeing,
    });
  } catch (error) {
    console.error(
      'Get student wellbeing error:',
      error
    );

    return res.status(500).json({
      message:
        'Failed to retrieve student wellbeing.',
    });
  }
});

export default router;
