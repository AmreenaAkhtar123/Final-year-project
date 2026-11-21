
import express from 'express';
import multer from 'multer';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { randomUUID } from 'node:crypto';

import User from '../models/User.js';
import authMiddleware from '../middleware/auth_middleware.js';

const router = express.Router();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const uploadDirectory = path.join(
  __dirname,
  '../uploads/profile-images',
);

fs.mkdirSync(uploadDirectory, { recursive: true });

const allowedTypes = {
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
};

const storage = multer.diskStorage({
  destination: (req, file, callback) => {
    callback(null, uploadDirectory);
  },

  filename: (req, file, callback) => {
    const extension = allowedTypes[file.mimetype];

    callback(
      null,
      `${req.user.userId}-${randomUUID()}.${extension}`,
    );
  },
});

const upload = multer({
  storage,
  limits: {
    fileSize: 5 * 1024 * 1024,
  },
  fileFilter: (req, file, callback) => {
    if (!allowedTypes[file.mimetype]) {
      return callback(
        new Error('Only JPG, PNG, and WEBP images are allowed.'),
      );
    }

    callback(null, true);
  },
});

// Upload or replace the authenticated user's profile picture.
router.post(
  '/api/profile/image',
  authMiddleware,
  upload.single('file'),
  async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({
          message: 'Please select a profile picture.',
        });
      }

      const user = await User.findById(req.user.userId);

      if (!user) {
        fs.unlinkSync(req.file.path);

        return res.status(404).json({
          message: 'User not found.',
        });
      }

      const previousImage = user.profileImage;

      user.profileImage = req.file.filename;

      await user.save();

      // Remove the previous image after the new image is saved.
      if (previousImage) {
        const previousPath = path.join(
          uploadDirectory,
          path.basename(previousImage),
        );

        if (fs.existsSync(previousPath)) {
          fs.unlinkSync(previousPath);
        }
      }

      return res.status(200).json({
        message: 'Profile picture updated successfully.',
        profileImage: user.profileImage,
      });
    } catch (error) {
      console.error('Profile image upload error:', error);

      if (req.file && fs.existsSync(req.file.path)) {
        fs.unlinkSync(req.file.path);
      }

      return res.status(500).json({
        message: 'Failed to upload profile picture.',
      });
    }
  },
);

// Retrieve the authenticated user's profile picture.
router.get(
  '/api/profile/image',
  authMiddleware,
  async (req, res) => {
    try {
      const user = await User.findById(req.user.userId);

      if (!user) {
        return res.status(404).json({
          message: 'User not found.',
        });
      }

      if (!user.profileImage) {
        return res.status(404).json({
          message: 'No profile picture found.',
        });
      }

      const imagePath = path.join(
        uploadDirectory,
        path.basename(user.profileImage),
      );

      if (!fs.existsSync(imagePath)) {
        return res.status(404).json({
          message: 'Profile picture file not found.',
        });
      }

      res.setHeader('Cache-Control', 'private, no-store');

      return res.sendFile(imagePath);
    } catch (error) {
      console.error('Profile image retrieval error:', error);

      return res.status(500).json({
        message: 'Failed to retrieve profile picture.',
      });
    }
  },
);

// Remove the authenticated user's profile picture.
router.delete(
  '/api/profile/image',
  authMiddleware,
  async (req, res) => {
    try {
      const user = await User.findById(req.user.userId);

      if (!user) {
        return res.status(404).json({
          message: 'User not found.',
        });
      }

      if (user.profileImage) {
        const imagePath = path.join(
          uploadDirectory,
          path.basename(user.profileImage),
        );

        if (fs.existsSync(imagePath)) {
          fs.unlinkSync(imagePath);
        }
      }

      user.profileImage = '';

      await user.save();

      return res.status(200).json({
        message: 'Profile picture removed successfully.',
      });
    } catch (error) {
      console.error('Profile image deletion error:', error);

      return res.status(500).json({
        message: 'Failed to remove profile picture.',
      });
    }
  },
);

export default router;
