
import express from 'express';

const MAX_ATTEMPTS = 2;

// Wait helper
const wait = (ms) =>
  new Promise((resolve) => setTimeout(resolve, ms));

// Determine whether the error is temporary.
function isTemporaryGeminiError(error) {
  const status = error?.status ?? error?.statusCode;

  return (
    [429, 500, 502, 503, 504].includes(status) ||
    ['ECONNRESET', 'ETIMEDOUT', 'ECONNREFUSED'].includes(
      error?.cause?.code,
    )
  );
}

// Read Google's Retry-After header.
function getRetryDelay(error, attempt) {
  const retryAfter = error?.headers?.get?.('retry-after');

  if (retryAfter) {
    const seconds = Number(retryAfter);

    if (Number.isFinite(seconds) && seconds >= 0) {
      return Math.min(seconds * 1000, 60000);
    }

    const retryDate = Date.parse(retryAfter);

    if (!Number.isNaN(retryDate)) {
      return Math.min(
        Math.max(retryDate - Date.now(), 0),
        60000,
      );
    }
  }

  return Math.min(1000 * 2 ** (attempt - 1), 10000);
}

// Call Gemini with limited retries.
async function createMoodInteraction(ai, request) {
  for (let attempt = 1; attempt <= MAX_ATTEMPTS; attempt++) {
    try {
      return await ai.interactions.create(request);
    } catch (error) {
      const temporary = isTemporaryGeminiError(error);

      if (!temporary || attempt === MAX_ATTEMPTS) {
        throw error;
      }

      const delay = getRetryDelay(error, attempt);

      console.warn(
        `Gemini temporarily unavailable. ` +
        `Retrying attempt ${attempt + 1}/${MAX_ATTEMPTS} ` +
        `after ${Math.ceil(delay / 1000)} seconds.`,
      );

      await wait(delay);
    }
  }
}

export default function createMoodAnalysisRouter(ai) {
  const router = express.Router();

  router.post('/api/mood/analyze', async (req, res) => {
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

      const request = {
        model: 'gemini-3.5-flash-lite',

        system_instruction: moodInstructions,

        input: `
Analyze this MindMate daily check-in:

Overall mood: ${moodData.mood}
Mood intensity: ${moodData.moodIntensity}/10
Emotions: ${moodData.emotions.join(', ') || 'None selected'}
Energy level: ${moodData.energyLevel}/10
Sleep quality: ${moodData.sleepQuality}/10
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
      };

      // Gemini request with retry handling
      const interaction = await createMoodInteraction(
        ai,
        request,
      );

      console.log('Mood AI response received.');

      const outputText = interaction.output_text;

      if (!outputText) {
        console.error('Mood AI returned no output.');

        return res.status(502).json({
          error: 'Mood AI returned an empty response.',
          code: 'MOOD_AI_EMPTY_RESPONSE',
        });
      }

      let analysis;

      try {
        analysis = JSON.parse(outputText);
      } catch (parseError) {
        console.error(
          'Failed to parse Mood AI JSON:',
          parseError.message,
        );

        return res.status(502).json({
          error: 'Invalid response received from Mood AI.',
          code: 'MOOD_AI_INVALID_RESPONSE',
        });
      }

      console.log('Mood AI analysis:');
      console.log(JSON.stringify(analysis, null, 2));
      console.log('========================================');

      return res.json(analysis);

    } catch (error) {
      const status = error?.status ?? error?.statusCode;

      console.error('============== MOOD AI ERROR ==============');
      console.error('Status:', status);
      console.error('Message:', error?.message);
      console.error('===========================================');

      // Temporary Gemini service errors
      if (isTemporaryGeminiError(error)) {
        const retryAfter = error?.headers?.get?.('retry-after');
        const retrySeconds =
          Number.isFinite(Number(retryAfter)) &&
          retryAfter !== null
            ? Math.max(1, Number(retryAfter))
            : 30;

        return res.status(503).json({
          error:
            'MindMate AI is temporarily busy. Please try again shortly.',
          code: 'MOOD_AI_TEMPORARILY_UNAVAILABLE',
          retryAfterSeconds: retrySeconds,
        });
      }

      return res.status(500).json({
        error:
          'Unable to analyze your check-in with MindMate AI.',
        code: 'MOOD_AI_ERROR',
      });
    }
  });

  return router;
}
