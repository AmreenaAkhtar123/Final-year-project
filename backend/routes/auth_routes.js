import express from 'express';
import bcrypt from 'bcrypt';
import User from '../models/User.js';

const router = express.Router();

router.post('/api/auth/signup', async (req, res) => {
  try {
    const {
      fullName,
      email,
      dateOfBirth,
      gender,
      password,
    } = req.body;

    // Check required fields
    if (!fullName || !email || !dateOfBirth || !password) {
      return res.status(400).json({
        message: 'Please provide all required fields.',
      });
    }

    // Normalize email
    const normalizedEmail = email.trim().toLowerCase();

    // Check if email already exists
    const existingUser = await User.findOne({
      email: normalizedEmail,
    });

    if (existingUser) {
      return res.status(409).json({
        message: 'An account with this email already exists.',
      });
    }

    // Validate date
    const parsedDateOfBirth = new Date(dateOfBirth);

    if (Number.isNaN(parsedDateOfBirth.getTime())) {
      return res.status(400).json({
        message: 'Invalid date of birth.',
      });
    }

    // Hash password before saving
    const hashedPassword = await bcrypt.hash(password, 12);

    // Create user
    const user = await User.create({
      fullName: fullName.trim(),
      email: normalizedEmail,
      dateOfBirth: parsedDateOfBirth,
      gender: gender || null,
      password: hashedPassword,
    });

    // Never send the password back
    return res.status(201).json({
      message: 'Account created successfully.',
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        dateOfBirth: user.dateOfBirth,
        gender: user.gender,
      },
    });
  } catch (error) {
    console.error('Signup error:', error);

    return res.status(500).json({
      message: 'Something went wrong while creating the account.',
    });
  }
});

router.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Check required fields
    if (!email || !password) {
      return res.status(400).json({
        message: 'Email and password are required.',
      });
    }

    // Normalize email
    const normalizedEmail = email.trim().toLowerCase();

    // Find user
    const user = await User.findOne({
      email: normalizedEmail,
    });

    if (!user) {
      return res.status(401).json({
        message: 'Incorrect email or password.',
      });
    }

    // Compare password with stored bcrypt hash
    const passwordMatches = await bcrypt.compare(
      password,
      user.password,
    );

    if (!passwordMatches) {
      return res.status(401).json({
        message: 'Incorrect email or password.',
      });
    }

    // Successful login
    return res.status(200).json({
      message: 'Login successful.',
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        dateOfBirth: user.dateOfBirth,
        gender: user.gender,
      },
    });
  } catch (error) {
    console.error('Login error:', error);

    return res.status(500).json({
      message: 'Something went wrong while logging in.',
    });
  }
});

router.get('/api/auth/profile', async (req, res) => {
  try {
    const { email } = req.query;

    if (!email) {
      return res.status(400).json({
        message: 'Email is required.',
      });
    }

    const user = await User.findOne({
      email: email.toLowerCase().trim(),
    }).select('-password');

    if (!user) {
      return res.status(404).json({
        message: 'User not found.',
      });
    }

    res.status(200).json({
      message: 'Profile retrieved successfully.',
      user,
    });
  } catch (error) {
    console.error('Get profile error:', error);

    res.status(500).json({
      message: 'Failed to retrieve profile.',
    });
  }
});

router.put('/api/auth/profile', async (req, res) => {
  try {
    const {
      email,
      fullName,
      dateOfBirth,
      gender,
      phone,
      bio,
      occupation,
      educationLevel,
    } = req.body;

    if (!email) {
      return res.status(400).json({
        message: 'Email is required.',
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

    if (fullName !== undefined) {
      user.fullName = fullName;
    }

    if (dateOfBirth !== undefined && dateOfBirth !== null) {
      user.dateOfBirth = new Date(dateOfBirth);
    }

    if (gender !== undefined) {
      user.gender = gender;
    }

    if (phone !== undefined) {
      user.phone = phone;
    }

    if (bio !== undefined) {
      user.bio = bio;
    }

    if (occupation !== undefined) {
      user.occupation = occupation;
    }

    if (educationLevel !== undefined) {
      user.educationLevel = educationLevel;
    }

    await user.save();

    const safeUser = user.toObject();
    delete safeUser.password;

    res.status(200).json({
      message: 'Profile updated successfully.',
      user: safeUser,
    });
  } catch (error) {
    console.error('Update profile error:', error);

    res.status(500).json({
      message: 'Failed to update profile.',
    });
  }
});

router.put('/api/auth/change-password', async (req, res) => {
  try {
    const {
      email,
      currentPassword,
      newPassword,
    } = req.body;

    if (!email || !currentPassword || !newPassword) {
      return res.status(400).json({
        message: 'All password fields are required.',
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

    // Verify the current password.
    const isCurrentPasswordCorrect = await bcrypt.compare(
      currentPassword,
      user.password,
    );

    if (!isCurrentPasswordCorrect) {
      return res.status(401).json({
        message: 'Current password is incorrect.',
      });
    }

    // Make sure the new password is different.
    const isSamePassword = await bcrypt.compare(
      newPassword,
      user.password,
    );

    if (isSamePassword) {
      return res.status(400).json({
        message: 'New password must be different from your current password.',
      });
    }

    // Hash the new password before storing it.
    const hashedPassword = await bcrypt.hash(
      newPassword,
      12,
    );

    user.password = hashedPassword;

    await user.save();

    res.status(200).json({
      message: 'Password updated successfully.',
    });
  } catch (error) {
    console.error('Change password error:', error);

    res.status(500).json({
      message: 'Failed to update password.',
    });
  }
});

export default router;
