import express from 'express';
import User from '../models/User.js';
import CheckIn from '../models/CheckIn.js';

const router = express.Router();

router.post('/api/check-ins', async (req, res) => {
  try {
    const {
      email,
      mood,
      moodIntensity,
      emotions,
      energyLevel,
      sleepQuality,
      factors,
      reflection,
    } = req.body;

    if (!email) {
      return res.status(400).json({
        message: 'Email is required.',
      });
    }

    if (!mood) {
      return res.status(400).json({
        message: 'Mood is required.',
      });
    }

    if (moodIntensity === undefined || moodIntensity === null) {
      return res.status(400).json({
        message: 'Mood intensity is required.',
      });
    }

    if (energyLevel === undefined || energyLevel === null) {
      return res.status(400).json({
        message: 'Energy level is required.',
      });
    }

    if (sleepQuality === undefined || sleepQuality === null) {
      return res.status(400).json({
        message: 'Sleep quality is required.',
      });
    }

    const user = await User.findOne({
      email: email.toLowerCase().trim(),
    });

    if (!user) {
      return res.status(404).json({
        message: 'User not found.',
      });
    }

    const checkIn = await CheckIn.create({
      email: user.email,
      mood,
      moodIntensity,
      emotions: Array.isArray(emotions) ? emotions : [],
      energyLevel,
      sleepQuality,
      factors: Array.isArray(factors) ? factors : [],
      reflection: reflection ?? '',
    });

    res.status(201).json({
      message: 'Check-in saved successfully.',
      checkIn,
    });
  } catch (error) {
    console.error('Save check-in error:', error);

    res.status(500).json({
      message: 'Failed to save check-in.',
    });
  }
});

router.get('/api/check-ins', async (req, res) => {
  try {
    const { email } = req.query;

    if (!email) {
      return res.status(400).json({
        message: 'Email is required.',
      });
    }

    const checkIns = await CheckIn.find({
      email: email.toLowerCase().trim(),
    }).sort({
      createdAt: -1,
    });

    res.status(200).json({
      message: 'Check-ins retrieved successfully.',
      checkIns,
    });
  } catch (error) {
    console.error('Get check-ins error:', error);

    res.status(500).json({
      message: 'Failed to retrieve check-ins.',
    });
  }
});

export default router;
