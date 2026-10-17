import express from 'express';
import mongoose from 'mongoose';
import User from '../models/User.js';
import MoodTracker from '../models/MoodTracker.js';

const router = express.Router();

router.post('/api/mood-tracker', async (req, res) => {
  try {
    const {
      email,
      mood,
      moodIntensity,
      factors,
      note,
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

    if (
      moodIntensity === undefined ||
      moodIntensity === null
    ) {
      return res.status(400).json({
        message: 'Mood intensity is required.',
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

    const moodTracker = await MoodTracker.create({
      email: user.email,
      mood,
      moodIntensity,
      factors: Array.isArray(factors) ? factors : [],
      note: note ?? '',
    });

    return res.status(201).json({
      message: 'Mood entry saved successfully.',
      moodTracker,
    });
  } catch (error) {
    console.error('Save mood tracker error:', error);

    return res.status(500).json({
      message: 'Failed to save mood entry.',
    });
  }
});

router.get('/api/mood-tracker', async (req, res) => {
  try {
    const { email } = req.query;

    if (!email) {
      return res.status(400).json({
        message: 'Email is required.',
      });
    }

    const normalizedEmail = email.toLowerCase().trim();

    const user = await User.findOne({
      email: normalizedEmail,
    });

    if (!user) {
      return res.status(404).json({
        message: 'User not found.',
      });
    }

    const moods = await MoodTracker.find({
      email: normalizedEmail,
    }).sort({
      createdAt: -1,
    });

    return res.status(200).json({
      message: 'Mood history retrieved successfully.',
      moods,
    });
  } catch (error) {
    console.error('Get mood history error:', error);

    return res.status(500).json({
      message: 'Failed to retrieve mood history.',
    });
  }
});

router.delete('/api/mood-tracker/:id', async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        message: 'Invalid mood entry ID.',
      });
    }

    const deletedMood = await MoodTracker.findByIdAndDelete(id);

    if (!deletedMood) {
      return res.status(404).json({
        message: 'Mood entry not found.',
      });
    }

    return res.status(200).json({
      message: 'Mood entry deleted successfully.',
    });
  } catch (error) {
    console.error('Delete mood error:', error);

    return res.status(500).json({
      message: 'Failed to delete mood entry.',
    });
  }
});

export default router;
