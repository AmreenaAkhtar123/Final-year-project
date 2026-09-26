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
    const { message, previousInteractionId } = req.body;

    if (!message || typeof message !== 'string') {
      return res.status(400).json({
        error: 'Message is required.',
      });
    }

    if (
      previousInteractionId !== undefined &&
      previousInteractionId !== null &&
      typeof previousInteractionId !== 'string'
    ) {
      return res.status(400).json({
        error: 'Invalid previous interaction ID.',
      });
    }

    console.log('========================================');
    console.log('User message:', message);

    if (previousInteractionId) {
      console.log(
        'Continuing interaction:',
        previousInteractionId,
      );
    } else {
      console.log('Starting new conversation.');
    }

    res.setHeader('Content-Type', 'application/x-ndjson');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');

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

Conversation behavior:
- Use the conversation history provided through the interaction history.
- Remember relevant information the user has already shared in this conversation.
- When the user refers to something previously mentioned, use that context naturally.
- Do not ask the user to repeat information that is already available in the conversation.
- Do not pretend to remember information that is not actually present in the conversation.
- Do not invent personal information about the user.
- If the user's new message depends on earlier context, use that context before responding.

Response style:
- Give thoughtful, moderately detailed responses.
- Usually respond in around 2–5 short paragraphs.
- Use simple, natural, easy-to-understand language.
- Acknowledge the user's feelings before offering suggestions.
- Give practical guidance that is relevant to what the user said.
- When useful, provide 2–4 clear steps or suggestions.
- Avoid very long explanations unless the user asks for more detail.
- Do not overwhelm the user with too many suggestions at once.
- Avoid sounding robotic or repetitive.
- Do not repeatedly use phrases such as "I understand" or "That sounds difficult" unless they genuinely fit the situation.
- Do not give advice too quickly when the user appears to be sharing emotions.
- Ask a helpful follow-up question only when it would genuinely help continue the conversation.

Mental health boundaries:
- You are not a doctor, therapist, or emergency service.
- Do not diagnose mental health conditions.
- Do not claim certainty about a user's mental health condition.
- Do not recommend medication or changes to prescribed medication.
- For serious or urgent situations, encourage the user to seek appropriate professional or emergency support.
- If a user expresses immediate danger, intent to seriously harm themselves or someone else, prioritize immediate safety and encourage contacting local emergency services or a trusted person nearby.

Important:
- Focus on the user's current message while also using relevant earlier conversation context.
- Never invent conversation history.
- Never claim that you remember something that was not provided.
`;

    const geminiStart = Date.now();

    const interactionOptions = {
      model: 'gemini-3.5-flash-lite',

      system_instruction: mindMateInstructions,

      input: message,

      generation_config: {
        thinking_level: 'low',
        max_output_tokens: 500,
      },

      stream: true,
    };

    // Continue the existing conversation when an interaction ID
    // was provided by Flutter.
    if (previousInteractionId) {
      interactionOptions.previous_interaction_id =
        previousInteractionId;
    }

    console.log('Sending request to Gemini...');

    const stream = await ai.interactions.create(
      interactionOptions,
    );

    let interactionId = null;

    for await (const event of stream) {
      console.log('GEMINI EVENT:');
      console.log(JSON.stringify(event, null, 2));

      // The first event contains the interaction ID.
      //
      // Flutter needs this ID so that the next message can
      // continue this same conversation.
      if (event.event_type === 'interaction.created') {
        interactionId = event.interaction?.id ?? null;

        console.log(
          'Gemini interaction ID:',
          interactionId,
        );

        if (interactionId) {
          res.write(
            JSON.stringify({
              type: 'interaction_id',
              interactionId: interactionId,
            }) + '\n',
          );
        }
      }

      // Stream generated text to Flutter.
      if (
        event.event_type === 'step.delta' &&
        event.delta?.type === 'text' &&
        event.delta.text
      ) {
        console.log(
          'TEXT CHUNK:',
          event.delta.text,
        );

        res.write(
          JSON.stringify({
            type: 'text',
            text: event.delta.text,
          }) + '\n',
        );
      }

      // Gemini finished this interaction.
      if (event.event_type === 'interaction.completed') {
        console.log('GEMINI COMPLETED');

        // In case the interaction ID was not captured from
        // interaction.created for some reason, try the
        // completed event as a fallback.
        if (!interactionId) {
          interactionId =
            event.interaction?.id ?? null;

          if (interactionId) {
            console.log(
              'Gemini interaction ID from completed event:',
              interactionId,
            );

            res.write(
              JSON.stringify({
                type: 'interaction_id',
                interactionId: interactionId,
              }) + '\n',
            );
          }
        }

        const geminiTime =
          Date.now() - geminiStart;

        const totalTime =
          Date.now() - startTime;

        console.log(
          `Gemini stream time: ${geminiTime} ms`,
        );

        console.log(
          `Total request time: ${totalTime} ms`,
        );

        res.write(
          JSON.stringify({
            type: 'done',
          }) + '\n',
        );
      }
    }

    console.log('Request completed.');
    console.log('========================================');

    res.end();
  } catch (error) {
    console.error(
      '================ GEMINI ERROR ================',
    );

    console.error(error);

    console.error(
      '================================================',
    );

    if (!res.headersSent) {
      return res.status(500).json({
        error:
          'Unable to get a response from MindMate AI.',
      });
    }

    res.write(
      JSON.stringify({
        type: 'error',
        message:
          'Unable to get a response from MindMate AI.',
      }) + '\n',
    );

    res.end();
  }
});

app.listen(port, () => {
  console.log(
    `MindMate backend running on port ${port}`,
  );
});