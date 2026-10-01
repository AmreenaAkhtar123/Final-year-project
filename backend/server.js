import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import mongoose from 'mongoose';
import { GoogleGenAI } from '@google/genai';

import bcrypt from 'bcrypt';
import User from './models/User.js';
import CheckIn from './models/CheckIn.js';

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

//Adding the SIGNUP route
app.post('/api/auth/signup', async (req, res) => {
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


//Adding the LOGIN route
app.post('/api/auth/login', async (req, res) => {
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


//Get the USER profile
app.get('/api/auth/profile', async (req, res) => {
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

// UPDATE user profile
app.put('/api/auth/profile', async (req, res) => {
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

//Update the password
app.put('/api/auth/change-password', async (req, res) => {
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

//Check-ins
app.post('/api/check-ins', async (req, res) => {
  try {
    const {
      email,
      mood,
      moodIntensity,
      emotions,
      energyLevel,
      sleepQuality,
      factors,
      reflection,
    } = req.body;

    if (!email) {
      return res.status(400).json({
        message: 'Email is required.',
      });
    }

    if (!mood) {
      return res.status(400).json({
        message: 'Mood is required.',
      });
    }

    if (moodIntensity === undefined || moodIntensity === null) {
      return res.status(400).json({
        message: 'Mood intensity is required.',
      });
    }

    if (energyLevel === undefined || energyLevel === null) {
      return res.status(400).json({
        message: 'Energy level is required.',
      });
    }

    if (sleepQuality === undefined || sleepQuality === null) {
      return res.status(400).json({
        message: 'Sleep quality is required.',
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

    const checkIn = await CheckIn.create({
      email: user.email,
      mood,
      moodIntensity,
      emotions: Array.isArray(emotions) ? emotions : [],
      energyLevel,
      sleepQuality,
      factors: Array.isArray(factors) ? factors : [],
      reflection: reflection ?? '',
    });

    res.status(201).json({
      message: 'Check-in saved successfully.',
      checkIn,
    });
  } catch (error) {
    console.error('Save check-in error:', error);

    res.status(500).json({
      message: 'Failed to save check-in.',
    });
  }
});

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

app.post('/api/mood/analyze', async (req, res) => {
  try {
    const {
      mood,
      moodIntensity,
      emotions,
      energyLevel,
      sleepQuality,
      factors,
      reflection,
    } = req.body;

    // Basic validation
    if (!mood || typeof mood !== 'string') {
      return res.status(400).json({
        error: 'Mood is required.',
      });
    }

    if (
      typeof moodIntensity !== 'number' ||
      typeof energyLevel !== 'number' ||
      typeof sleepQuality !== 'number'
    ) {
      return res.status(400).json({
        error:
          'Mood intensity, energy level, and sleep quality are required.',
      });
    }

    const moodData = {
      mood,
      moodIntensity,
      emotions: Array.isArray(emotions) ? emotions : [],
      energyLevel,
      sleepQuality,
      factors: Array.isArray(factors) ? factors : [],
      reflection:
        typeof reflection === 'string'
          ? reflection.trim()
          : '',
    };

    console.log('========================================');
    console.log('Mood AI analysis request:');
    console.log(JSON.stringify(moodData, null, 2));

    const moodInstructions = `
You are MindMate's mood and emotion analysis assistant.

Your job is to provide a brief, supportive, non-clinical interpretation
of a user's daily check-in.

Analyze the information provided by the user and return ONLY valid JSON
matching the requested schema.

IMPORTANT RULES:

- Do not diagnose any mental health condition.
- Do not describe the user as having a disorder.
- Do not make clinical judgments.
- Treat intensity as a non-clinical description of how strongly the user
  reports experiencing their mood.
- Do not provide medication advice.
- Do not make assumptions about information the user did not provide.
- Base the analysis only on the supplied check-in information.
- Keep the summary supportive and easy to understand.
- Suggestions should be simple, practical, and appropriate for everyday
  emotional wellbeing.
- Do not overwhelm the user with advice.
- If the reflection contains signs of serious emotional distress or
  immediate danger, prioritize encouraging the user to seek immediate
  human support and appropriate emergency help rather than giving
  ordinary wellbeing suggestions.
- Never provide instructions or methods for self-harm or harming others.

The primary emotion should be selected from the emotions explicitly
provided by the user when possible. If no emotions were selected,
infer a cautious primary emotional state from the mood and other
information without making a clinical judgment.

The intensity field should use one of:
- Low
- Mild
- Moderate
- High

The suggestions should normally contain 2 or 3 short suggestions.
`;

    const interaction = await ai.interactions.create({
      model: 'gemini-3.5-flash-lite',

      system_instruction: moodInstructions,

      input: `
Analyze this MindMate daily check-in:

Overall mood: ${mood}
Mood intensity: ${moodIntensity}/10
Emotions: ${moodData.emotions.join(', ') || 'None selected'}
Energy level: ${energyLevel}/10
Sleep quality: ${sleepQuality}/10
Factors affecting mood: ${moodData.factors.join(', ') || 'None selected'}
Reflection: ${moodData.reflection || 'No reflection provided'}
      `,

      generation_config: {
        thinking_level: 'low',
        max_output_tokens: 400,
      },

      response_format: {
        type: 'text',
        mime_type: 'application/json',
        schema: {
          type: 'object',
          properties: {
            primaryEmotion: {
              type: 'string',
              description:
                'The main emotional state reflected by the check-in.',
            },
            intensity: {
              type: 'string',
              enum: [
                'Low',
                'Mild',
                'Moderate',
                'High',
              ],
              description:
                'A non-clinical description of the reported emotional intensity.',
            },
            summary: {
              type: 'string',
              description:
                'A short supportive interpretation of the check-in.',
            },
            suggestions: {
              type: 'array',
              items: {
                type: 'string',
              },
              description:
                'Two or three practical wellbeing suggestions.',
            },
          },
          required: [
            'primaryEmotion',
            'intensity',
            'summary',
            'suggestions',
          ],
        },
      },
    });

    console.log('Mood AI response received.');

    const outputText = interaction.output_text;

    if (!outputText) {
      console.error('Mood AI returned no output.');

      return res.status(500).json({
        error: 'Mood AI returned an empty response.',
      });
    }

    let analysis;

    try {
      analysis = JSON.parse(outputText);
    } catch (parseError) {
      console.error(
        'Failed to parse Mood AI JSON:',
        outputText,
      );

      return res.status(500).json({
        error: 'Invalid response received from Mood AI.',
      });
    }

    console.log('Mood AI analysis:');
    console.log(JSON.stringify(analysis, null, 2));
    console.log('========================================');

    return res.json(analysis);
  } catch (error) {
    console.error(
      '============== MOOD AI ERROR ==============',
    );

    console.error(error);

    console.error(
      '===========================================',
    );

    return res.status(500).json({
      error:
        'Unable to analyze your check-in with MindMate AI.',
    });
  }
});


app.listen(port, () => {
  console.log(
    `MindMate backend running on port ${port}`,
  );
});