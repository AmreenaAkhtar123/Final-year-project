import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import mongoose from 'mongoose';
import { GoogleGenAI } from '@google/genai';

import authRoutes from './routes/auth_routes.js';
import checkinRoutes from './routes/checkin_routes.js';
import progressRoutes from './routes/progress_routes.js';
import studentWellbeingRoutes from './routes/student_wellbeing_routes.js';
import moodRoutes from './routes/mood_routes.js';
import createChatRouter from './routes/chat_routes.js';
import createMoodAnalysisRouter from './routes/mood_analysis_routes.js';

dotenv.config();

const mongoUri = process.env.MONGODB_URI;

if (!mongoUri) {
  console.error('MONGODB_URI is not defined in .env');
  process.exit(1);
}

mongoose
  .connect(mongoUri)
  .then(() => {
    console.log('MongoDB Atlas connected successfully.');
  })
  .catch((error) => {
    console.error('MongoDB Atlas connection failed:', error);
  });

const app = express();
const port = process.env.PORT || 5000;

const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

app.use(cors());
app.use(express.json());

app.use(authRoutes);
app.use(checkinRoutes);
app.use(progressRoutes);
app.use(studentWellbeingRoutes);
app.use(moodRoutes);
app.use(createChatRouter(ai));
app.use(createMoodAnalysisRouter(ai));

app.get('/', (req, res) => {
  res.json({ message: 'MindMate backend is running.' });
});

app.listen(port, () => {
  console.log(`MindMate backend running on port ${port}`);
});
