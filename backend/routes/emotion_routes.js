
import express from 'express';

const router = express.Router();

const mlServiceUrl = (
  process.env.ML_SERVICE_URL || 'http://127.0.0.1:8000'
).replace(/\/+$/, '');

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
        message: 'The emotion analysis service could not process your text.',
      });
    }

    if (
      typeof result.emotion !== 'string' ||
      typeof result.confidence !== 'number'
    ) {
      console.error('Invalid ML response:', result);

      return res.status(502).json({
        success: false,
        message: 'The emotion analysis service returned an invalid result.',
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

export default function createEmotionRouter() {
  return router;
}
