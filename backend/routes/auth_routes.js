import jwt from 'jsonwebtoken';
import express from 'express';
import bcrypt from 'bcrypt';
import User from '../models/User.js';

import { randomInt, createHash } from 'crypto';
import { sendPasswordResetOtp } from '../services/email_service.js';

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

    // Ensure JWT secret is configured.
    if (!process.env.JWT_SECRET) {
      console.error('JWT_SECRET is not configured.');

      return res.status(500).json({
        message: 'Authentication service is not configured.',
      });
    }

    // Generate authentication token.
    const token = jwt.sign(
      {
        userId: user._id.toString(),
      },
      process.env.JWT_SECRET,
      {
        expiresIn: process.env.JWT_EXPIRES_IN || '7d',
      },
    );

    // Successful login
    return res.status(200).json({
      message: 'Login successful.',
      token,
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



router.post('/api/auth/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;

    if (!email || typeof email !== 'string') {
      return res.status(400).json({
        message: 'Please provide a valid email address.',
      });
    }

    const normalizedEmail = email.trim().toLowerCase();

    const genericMessage =
      'If an account exists with this email, a verification code has been sent.';

    const user = await User.findOne({
      email: normalizedEmail,
    });

    // Do not reveal whether an account exists.
    if (!user) {
      return res.status(200).json({
        message: genericMessage,
      });
    }

    const now = new Date();

    // Prevent repeated OTP requests within 60 seconds.
    if (
      user.resetPasswordOtpExpires &&
      user.resetPasswordOtpExpires.getTime() - now.getTime() > 4 * 60 * 1000
    ) {
      return res.status(200).json({
        message: genericMessage,
      });
    }

    // Generate a secure six-digit OTP.
    const otp = randomInt(100000, 1000000).toString();

    // Store only the SHA-256 hash of the OTP.
    user.resetPasswordOtpHash = createHash('sha256')
      .update(otp)
      .digest('hex');

    user.resetPasswordOtpExpires = new Date(
      now.getTime() + 5 * 60 * 1000,
    );

    user.resetPasswordOtpAttempts = 0;
    user.resetPasswordOtpVerifiedUntil = null;

    await user.save();

    try {
      await sendPasswordResetOtp(user.email, otp);
    } catch (emailError) {
      console.error('Password reset email delivery failed:', {
        recipient: user.email,
        message: emailError.message,
        code: emailError.code,
      });

      // Clear the unused OTP if email delivery fails.
      user.resetPasswordOtpHash = null;
      user.resetPasswordOtpExpires = null;
      user.resetPasswordOtpAttempts = 0;
      user.resetPasswordOtpVerifiedUntil = null;

      await user.save();

      return res.status(503).json({
        message: 'Unable to send the verification email right now. Please try again later.',
      });
    }

    return res.status(200).json({
      message: genericMessage,
    });
  } catch (error) {
    console.error('Forgot password error:', error);

    return res.status(500).json({
      message: 'Unable to process your request right now.',
    });
  }
});



router.post('/api/auth/verify-reset-otp', async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (
      !email ||
      typeof email !== 'string' ||
      !otp ||
      typeof otp !== 'string' ||
      !/^\d{6}$/.test(otp)
    ) {
      return res.status(400).json({
        message: 'Please provide a valid email and six-digit OTP.',
      });
    }

    const normalizedEmail = email.trim().toLowerCase();

    const user = await User.findOne({
      email: normalizedEmail,
    });

    if (!user || !user.resetPasswordOtpHash) {
      return res.status(400).json({
        message: 'Invalid or expired verification code.',
      });
    }

    const now = new Date();

    if (
      !user.resetPasswordOtpExpires ||
      user.resetPasswordOtpExpires <= now
    ) {
      user.resetPasswordOtpHash = null;
      user.resetPasswordOtpExpires = null;
      user.resetPasswordOtpAttempts = 0;
      user.resetPasswordOtpVerifiedUntil = null;

      await user.save();

      return res.status(400).json({
        message: 'Verification code has expired. Please request a new one.',
      });
    }

    if (user.resetPasswordOtpAttempts >= 5) {
      user.resetPasswordOtpHash = null;
      user.resetPasswordOtpExpires = null;
      user.resetPasswordOtpAttempts = 0;
      user.resetPasswordOtpVerifiedUntil = null;

      await user.save();

      return res.status(429).json({
        message: 'Too many incorrect attempts. Please request a new code.',
      });
    }

    const submittedOtpHash = createHash('sha256')
      .update(otp)
      .digest('hex');

    if (submittedOtpHash !== user.resetPasswordOtpHash) {
      user.resetPasswordOtpAttempts += 1;
      await user.save();

      return res.status(400).json({
        message: 'Invalid or expired verification code.',
      });
    }

    user.resetPasswordOtpVerifiedUntil = new Date(
      now.getTime() + 10 * 60 * 1000,
    );

    await user.save();

    return res.status(200).json({
      message: 'Email verified successfully.',
    });
  } catch (error) {
    console.error('Verify reset OTP error:', error);

    return res.status(500).json({
      message: 'Unable to verify the code right now.',
    });
  }
});


router.post('/api/auth/reset-password', async (req, res) => {
  try {
    const { email, newPassword, confirmPassword } = req.body;

    if (
      !email ||
      typeof email !== 'string' ||
      !newPassword ||
      typeof newPassword !== 'string' ||
      !confirmPassword ||
      typeof confirmPassword !== 'string'
    ) {
      return res.status(400).json({
        message: 'Please provide all required fields.',
      });
    }

    if (newPassword.length < 8) {
      return res.status(400).json({
        message: 'Password must contain at least 8 characters.',
      });
    }

    if (newPassword !== confirmPassword) {
      return res.status(400).json({
        message: 'Passwords do not match.',
      });
    }

    const normalizedEmail = email.trim().toLowerCase();

    const user = await User.findOne({
      email: normalizedEmail,
    });

    if (!user || !user.resetPasswordOtpVerifiedUntil) {
      return res.status(400).json({
        message: 'Please verify your email before resetting your password.',
      });
    }

    if (user.resetPasswordOtpVerifiedUntil <= new Date()) {
      user.resetPasswordOtpHash = null;
      user.resetPasswordOtpExpires = null;
      user.resetPasswordOtpAttempts = 0;
      user.resetPasswordOtpVerifiedUntil = null;

      await user.save();

      return res.status(400).json({
        message: 'Verification has expired. Please request a new code.',
      });
    }

    const isSamePassword = await bcrypt.compare(
      newPassword,
      user.password,
    );

    if (isSamePassword) {
      return res.status(400).json({
        message: 'New password must be different from your current password.',
      });
    }

    user.password = await bcrypt.hash(newPassword, 12);

    // Clear all password reset data after successful reset.
    user.resetPasswordOtpHash = null;
    user.resetPasswordOtpExpires = null;
    user.resetPasswordOtpAttempts = 0;
    user.resetPasswordOtpVerifiedUntil = null;

    await user.save();

    return res.status(200).json({
      message: 'Password reset successfully. Please log in with your new password.',
    });
  } catch (error) {
    console.error('Reset password error:', error);

    return res.status(500).json({
      message: 'Unable to reset your password right now.',
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
