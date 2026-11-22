
import mongoose from 'mongoose';

const userSchema = new mongoose.Schema(
  {
    fullName: {
      type: String,
      required: true,
      trim: true,
      minlength: 2,
      maxlength: 50,
    },

    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },

    dateOfBirth: {
      type: Date,
      required: true,
    },

    gender: {
      type: String,
      enum: [
        'Male',
        'Female',
        'Non-binary',
        'Prefer not to say',
      ],
      default: null,
    },

    phone: {
      type: String,
      default: '',
      trim: true,
    },

    bio: {
      type: String,
      default: '',
      trim: true,
      maxlength: 500,
    },

    profileImage: {
      type: String,
      default: '',
    },

    occupation: {
      type: String,
      default: '',
      trim: true,
    },

    educationLevel: {
      type: String,
      default: '',
      trim: true,
    },

    password: {
      type: String,
      required: true,
    },

    // Password reset OTP fields
    resetPasswordOtpHash: {
      type: String,
      default: null,
    },

    resetPasswordOtpExpires: {
      type: Date,
      default: null,
    },

    resetPasswordOtpAttempts: {
      type: Number,
      default: 0,
    },

    resetPasswordOtpVerifiedUntil: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
  },
);

const User = mongoose.model('User', userSchema);

export default User;
