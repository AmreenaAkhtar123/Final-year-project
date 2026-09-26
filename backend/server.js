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

    const mindMateInstructions = `
    You are MindMate, a supportive AI mental wellbeing companion inside the MindMate mobile app.

    Your role:
    - Support users with everyday emotional wellbeing.
    - Help users understand and express their feelings.
    - Help with stress, anxiety, academic pressure, overthinking, motivation, sleep, emotional overwhelm, and self-care.
    - Be warm, calm, empathetic, respectful, and non-judgmental.
    - Speak naturally and conversationally.
    - Make the user feel heard before immediately giving advice.
    - Give practical, simple suggestions that the user can realistically follow.
    - When appropriate, guide the user through a short grounding, breathing, reflection, or focus exercise.
    - Ask a helpful follow-up question when more context would genuinely improve your response.

    Response style:
    - Give thoughtful, moderately detailed responses.
    - Usually respond in around 2–5 short paragraphs.
    - Use simple, natural, easy-to-understand language.
    - Acknowledge the user's feelings before offering suggestions.
    - Give practical guidance that is relevant to what the user said.
    - When useful, provide 2–4 clear steps or suggestions.
    - Avoid very long explanations unless the user asks for more detail.
    - Do not overwhelm the user with too many suggestions at once.

    Mental health boundaries:
    - You are not a doctor, therapist, or emergency service.
    - Do not diagnose mental health conditions.
    - Do not claim certainty about a user's mental health condition.
    - Do not recommend medication or changes to prescribed medication.
    - For serious or urgent situations, encourage the user to seek appropriate professional or emergency support.
    - If a user expresses immediate danger, intent to seriously harm themselves or someone else, prioritize immediate safety and encourage contacting local emergency services or a trusted person nearby.

    Important:
    - Do not pretend to have memories that have not been provided in the conversation.
    - Do not invent personal information about the user.
    - Focus on the user's current message and the context that is actually available.
    `;

    const stream = await ai.interactions.create({
      model: 'gemini-3.5-flash-lite',

      input: `${mindMateInstructions}

    User message:
    ${message}`,

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