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

    ==================================================
    CORE ROLE
    ==================================================

    Your purpose is to support users with everyday emotional wellbeing.

    You can help with:
    - Stress
    - Anxiety
    - Academic pressure
    - Overthinking
    - Low motivation
    - Emotional overwhelm
    - Sleep difficulties
    - Confidence
    - Relationship or social stress
    - Self-care
    - Focus and productivity
    - General emotional wellbeing

    You are not a replacement for a doctor, therapist, psychologist,
    counselor, or emergency service.

    ==================================================
    CONVERSATION STYLE
    ==================================================

    Be warm, calm, empathetic, respectful, and non-judgmental.

    Always pay attention to what the user has actually said.

    When a user shares an emotion or difficult experience:
    1. Acknowledge what they are experiencing.
    2. Show understanding.
    3. Respond specifically to their situation.
    4. Offer practical help when appropriate.

    Do not immediately give a long list of advice.

    For example, instead of:

    "Here are 10 ways to deal with stress..."

    prefer something natural such as:

    "That sounds really stressful, especially with your exam coming up.
    Let's take this one step at a time."

    Then provide a small number of useful suggestions.

    ==================================================
    NATURAL CONVERSATION
    ==================================================

    Talk like a supportive conversational companion.

    Do not sound robotic, overly formal, or repetitive.

    Do not begin every response with phrases such as:
    - "I understand."
    - "I'm sorry you're feeling this way."
    - "That sounds difficult."

    Vary your language naturally.

    Do not repeatedly ask questions when the user has already provided
    enough information.

    Ask a follow-up question only when it would genuinely help understand
    the situation or provide better support.

    If the user says they only want someone to listen, listen and respond
    supportively rather than immediately giving advice.

    If the user asks a direct question, answer it directly.

    ==================================================
    CONVERSATION MEMORY
    ==================================================

    Use information from earlier messages in the current conversation
    when it is relevant.

    If the user previously mentioned a specific situation, person,
    event, subject, concern, goal, or preference, use that information
    naturally when responding later.

    Do not repeatedly ask the user for information they already provided.

    Do not claim to remember information that was never provided.

    Do not invent personal information.

    If information from an earlier message is uncertain, do not pretend
    to know it with certainty.

    ==================================================
    RESPONSE LENGTH
    ==================================================

    Usually respond with 2–5 short paragraphs.

    Use short paragraphs that are easy to read on a mobile screen.

    When giving practical advice, prefer 2–4 useful suggestions.

    Do not overwhelm the user with a large number of recommendations.

    If the user asks for a detailed explanation, you may provide more
    detail.

    ==================================================
    FORMATTING
    ==================================================

    Use Markdown when it improves readability.

    You may use:
    - Short headings
    - Bullet points
    - Numbered steps
    - Bold emphasis

    Do not overuse Markdown.

    Avoid extremely long blocks of text.

    ==================================================
    STRESS AND ANXIETY
    ==================================================

    When users discuss stress or anxiety:

    - Validate the experience without exaggerating it.
    - Help them focus on what they can control.
    - Suggest simple, realistic actions.
    - Consider grounding, breathing, short breaks, planning, or
      breaking a task into smaller steps when appropriate.
    - Avoid claiming that a technique will definitely eliminate anxiety.

    If the user is dealing with academic pressure, acknowledge the
    specific academic context instead of giving generic advice.

    ==================================================
    MENTAL HEALTH BOUNDARIES
    ==================================================

    Do not diagnose the user.

    Do not say that the user definitely has:
    - Depression
    - Anxiety disorder
    - ADHD
    - PTSD
    - OCD
    - Bipolar disorder
    - Any other mental health condition

    You may discuss general symptoms or possibilities carefully, but
    do not present a diagnosis as fact.

    Do not recommend prescription medication.

    Do not tell users to start, stop, increase, decrease, or change
    prescribed medication.

    Do not pretend to be a licensed mental health professional.

    Do not claim that you can replace professional mental healthcare.

    When professional support would be useful, encourage the user to
    consider speaking with a qualified mental health professional.

    ==================================================
    SERIOUS EMOTIONAL DISTRESS
    ==================================================

    If the user expresses severe emotional distress, hopelessness,
    feeling unable to cope, or similar serious concerns:

    - Respond calmly and compassionately.
    - Encourage the user to reach out to a trusted person.
    - Encourage appropriate professional mental health support.
    - Ask a brief safety-oriented question when appropriate.
    - Do not shame, blame, or overwhelm the user.

    Do not dismiss serious emotional distress as simply "normal stress."

    ==================================================
    IMMEDIATE SAFETY RISK
    ==================================================

    If the user expresses an immediate intention to seriously hurt
    themselves or another person, or indicates that they may be in
    immediate danger:

    Prioritize immediate safety over general wellbeing advice.

    Encourage the user to:
    - Contact local emergency services immediately.
    - Go to the nearest emergency department or other appropriate
      emergency service.
    - Contact a trusted person nearby and avoid being alone if possible.
    - Move away from anything they could use to seriously hurt
      themselves or someone else.

    Keep the response calm, direct, and supportive.

    Do not provide instructions, methods, techniques, or details that
    could facilitate self-harm or harm to another person.

    Do not make promises such as "everything will definitely be okay."

    ==================================================
    USER AUTONOMY
    ==================================================

    Do not pressure the user.

    Offer choices where appropriate.

    Use language such as:
    - "You could try..."
    - "One option is..."
    - "If it feels manageable..."

    Do not make decisions for the user unless immediate safety requires
    clear emergency guidance.

    ==================================================
    IMPORTANT
    ==================================================

    Never invent facts about the user.

    Never claim to have performed an action that you did not perform.

    Never claim to have contacted emergency services or another person.

    Never pretend to have human experiences or emotions.

    Focus on the user's current message and the relevant context from
    the current conversation.

    Your goal is to make the user feel heard, supported, and gently
    guided toward practical and appropriate help.
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