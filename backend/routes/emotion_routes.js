
import express from 'express';
import multer from 'multer';

const router = express.Router();

const mlServiceUrl = (
  process.env.ML_SERVICE_URL || 'http://127.0.0.1:8000'
).replace(/\/+$/, '');

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 25 * 1024 * 1024,
    files: 1,
  },
});

// --------------------------------------------------
// TEXT EMOTION — EXISTING ROUTE PRESERVED
// --------------------------------------------------

router.post('/api/emotion/text', async (req, res) => {
  const { text, language = 'english' } = req.body ?? {};

  if (typeof text !== 'string' || !text.trim()) {
    return res.status(400).json({
      success: false,
      message: 'Please enter some text to analyze.',
    });
  }

  if (text.length > 10000) {
    return res.status(400).json({
      success: false,
      message: 'Text must not exceed 10000 characters.',
    });
  }

  if (
    typeof language !== 'string' ||
    language.toLowerCase() !== 'english'
  ) {
    return res.status(400).json({
      success: false,
      message: 'The text emotion model currently supports English only.',
    });
  }

  try {
    const response = await fetch(
      `${mlServiceUrl}/predict/text-emotion`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Accept: 'application/json',
        },
        body: JSON.stringify({ text: text.trim() }),
        signal: AbortSignal.timeout(60000),
      },
    );

    const result = await response.json().catch(() => ({}));

    if (!response.ok) {
      console.error('ML service error:', response.status, result);

      return res.status(502).json({
        success: false,
        message:
          'The emotion analysis service could not process your text.',
      });
    }

    if (
      typeof result.emotion !== 'string' ||
      typeof result.confidence !== 'number'
    ) {
      console.error('Invalid ML response:', result);

      return res.status(502).json({
        success: false,
        message:
          'The emotion analysis service returned an invalid result.',
      });
    }

    return res.json({
      success: true,
      predicted_emotion: result.emotion,
      emotion: result.emotion,
      confidence: result.confidence,
      scores: result.scores,
    });
  } catch (error) {
    console.error('Text emotion request failed:', error.message);

    const timedOut = error.name === 'TimeoutError';

    return res.status(timedOut ? 504 : 503).json({
      success: false,
      message: timedOut
        ? 'Emotion analysis timed out. Please try again.'
        : 'The emotion analysis service is unavailable. Please try again.',
    });
  }
});

// --------------------------------------------------
// VOICE EMOTION — ENGLISH AND URDU
// --------------------------------------------------

router.post(
  '/api/emotion/voice',
  upload.single('file'),
  async (req, res) => {
    const language = (
      typeof req.body?.language === 'string'
        ? req.body.language
        : 'english'
    ).trim().toLowerCase();

    if (!['english', 'urdu'].includes(language)) {
      return res.status(400).json({
        success: false,
        message: "Language must be 'english' or 'urdu'.",
      });
    }

    if (!req.file || !req.file.buffer?.length) {
      return res.status(400).json({
        success: false,
        message: 'Please upload an audio recording.',
      });
    }

    try {
      const formData = new FormData();

      formData.append('language', language);

      formData.append(
        'file',
        new Blob([req.file.buffer], {
          type: req.file.mimetype || 'application/octet-stream',
        }),
        req.file.originalname || 'recording.wav',
      );

      const response = await fetch(
        `${mlServiceUrl}/predict/voice-emotion`,
        {
          method: 'POST',
          headers: {
            Accept: 'application/json',
          },
          body: formData,
          signal: AbortSignal.timeout(120000),
        },
      );

      const result = await response.json().catch(() => ({}));

      if (!response.ok) {
        console.error(
          'Voice ML service error:',
          response.status,
          result,
        );

        return res.status(
          response.status === 503 ? 503 : 502,
        ).json({
          success: false,
          message:
            result.detail ||
            'The voice emotion service could not process your audio.',
        });
      }

      if (
        typeof result.emotion !== 'string' ||
        typeof result.confidence !== 'number'
      ) {
        console.error('Invalid voice ML response:', result);

        return res.status(502).json({
          success: false,
          message:
            'The voice emotion service returned an invalid result.',
        });
      }

      return res.json({
        success: true,
        model: result.model,
        language: result.language || language,
        predicted_emotion: result.emotion,
        emotion: result.emotion,
        confidence: result.confidence,
        scores: result.scores,
      });
    } catch (error) {
      console.error(
        'Voice emotion request failed:',
        error.message,
      );

      const timedOut = error.name === 'TimeoutError';

      return res.status(timedOut ? 504 : 503).json({
        success: false,
        message: timedOut
          ? 'Voice emotion analysis timed out. Please try again.'
          : 'The voice emotion service is unavailable. Please try again.',
      });
    }
  },
);

// --------------------------------------------------
// EXPORT ROUTER
// --------------------------------------------------

export default function createEmotionRouter() {
  return router;
}
