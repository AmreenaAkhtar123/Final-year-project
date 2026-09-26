import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { GoogleGenAI } from '@google/genai';

dotenv.config();

const app = express();
const port = process.env.PORT || 5000;

// Check that the Gemini API key exists.
if (!process.env.GEMINI_API_KEY) {
  console.error('ERROR: GEMINI_API_KEY is missing from the .env file.');
  process.exit(1);
}

// Initialize Gemini.
const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

// Middleware.
app.use(cors());
app.use(express.json());

// Health check.
app.get('/', (req, res) => {
  res.json({
    message: 'MindMate backend is running.',
  });
});

// AI Chat endpoint.
app.post('/api/chat', async (req, res) => {
  try {
    const { message } = req.body;

    // Validate message.
    if (!message || typeof message !== 'string' || !message.trim()) {
      return res.status(400).json({
        error: 'Message is required.',
      });
    }

    // Send the user's message to Gemini.
    const interaction = await ai.interactions.create({
      model: 'gemini-3.8-flash',
      input: message.trim(),
      generation_config: {
        thinking_level: 'low',
      },
    });

    // Return Gemini's response.
    res.json({
      reply: interaction.output_text,
      interactionId: interaction.id,
    });
  }  catch (error) {
      console.error('================ GEMINI ERROR ================');
      console.error(error);
      console.error('================================================');

      res.status(500).json({
        error: 'Unable to get a response from MindMate AI.',
      });
    }
});

// Start server.
app.listen(port, () => {
  console.log(`MindMate backend running on port ${port}`);
});