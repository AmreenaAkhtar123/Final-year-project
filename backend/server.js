import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { GoogleGenAI } from '@google/genai';

dotenv.config();

const app = express();
const port = process.env.PORT || 5000;

const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    message: 'MindMate backend is running.',
  });
});


app.post('/api/chat', async (req, res) => {
  const startTime = Date.now();

  try {
    const { message } = req.body;

    if (!message || typeof message !== 'string') {
      return res.status(400).json({
        error: 'Message is required.',
      });
    }

    console.log('User message:', message);

    res.setHeader('Content-Type', 'application/x-ndjson');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');

    const geminiStart = Date.now();

    const stream = await ai.interactions.create({
      model: 'gemini-3.5-flash-lite',
      input: message,
      generation_config: {
        thinking_level: 'low',
        max_output_tokens: 500,
      },
      stream: true,
    });

    for await (const event of stream) {
      console.log('GEMINI EVENT:');
      console.log(JSON.stringify(event, null, 2));

      if (
        event.event_type === 'step.delta' &&
        event.delta?.type === 'text' &&
        event.delta.text
      ) {
        console.log('TEXT CHUNK:', event.delta.text);

        res.write(
          JSON.stringify({
            type: 'text',
            text: event.delta.text,
          }) + '\n',
        );
      }

      if (event.event_type === 'interaction.completed') {
        console.log('GEMINI COMPLETED');

        const geminiTime = Date.now() - geminiStart;
        const totalTime = Date.now() - startTime;

        console.log(`Gemini stream time: ${geminiTime} ms`);
        console.log(`Total request time: ${totalTime} ms`);

        res.write(
          JSON.stringify({
            type: 'done',
          }) + '\n',
        );
      }
    }

    res.end();
  } catch (error) {
    console.error('================ GEMINI ERROR ================');
    console.error(error);
    console.error('================================================');

    if (!res.headersSent) {
      return res.status(500).json({
        error: 'Unable to get a response from MindMate AI.',
      });
    }

    res.write(
      JSON.stringify({
        type: 'error',
        message: 'Unable to get a response from MindMate AI.',
      }) + '\n',
    );

    res.end();
  }
});


app.listen(port, () => {
  console.log(`MindMate backend running on port ${port}`);
});