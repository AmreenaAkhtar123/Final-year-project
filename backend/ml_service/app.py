
from pathlib import Path

import torch
from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from pydantic import BaseModel, Field
from transformers import (
    AutoModelForSequenceClassification,
    AutoTokenizer,
)

from services.voice_emotion import (
    load_voice_models,
    predict_voice_emotion,
)

BASE_DIR = Path(__file__).resolve().parent
MODEL_DIR = BASE_DIR / "models" / "text_emotion"

app = FastAPI(
    title="MindMate ML Service",
    version="1.1.0",
)

# Use CPU for the initial integration.
device = torch.device("cpu")

tokenizer = None
model = None
id2label = {}

voice_models_loaded = False

MAX_AUDIO_SIZE = 25 * 1024 * 1024  # 25 MB


@app.on_event("startup")
def load_model():
    """Load Text Emotion first, then attempt to load both voice models."""
    global tokenizer, model, id2label, voice_models_loaded

    # Preserve the existing Text Emotion initialization.
    if not MODEL_DIR.is_dir():
        raise RuntimeError(f"Model folder not found: {MODEL_DIR}")

    tokenizer = AutoTokenizer.from_pretrained(
        str(MODEL_DIR),
        local_files_only=True,
    )

    model = AutoModelForSequenceClassification.from_pretrained(
        str(MODEL_DIR),
        local_files_only=True,
        use_safetensors=True,
    )

    model.to(device)
    model.eval()

    id2label = {
        int(key): value
        for key, value in model.config.id2label.items()
    }

    print("MindMate text emotion model loaded.")
    print("Text emotion labels:", id2label)

    # Voice loading is separate. A voice-model loading failure
    # should not prevent the existing text model from starting.
    try:
        load_voice_models()
        voice_models_loaded = True
        print("MindMate voice emotion models loaded.")
    except Exception as exc:
        voice_models_loaded = False
        print("Voice emotion models failed to load:", repr(exc))
        print("Text Emotion remains available.")


class PredictionRequest(BaseModel):
    text: str = Field(min_length=1, max_length=10000)


@app.get("/health")
def health():
    return {
        "status": "ok" if model is not None else "degraded",
        "model_loaded": model is not None,
        "model_type": "DistilBERT",
        "voice_models_loaded": voice_models_loaded,
    }


@app.post("/predict/text-emotion")
def predict_text_emotion(request: PredictionRequest):
    # Existing Text Emotion endpoint preserved.
    if model is None or tokenizer is None:
        raise HTTPException(
            status_code=503,
            detail="Emotion model is not loaded.",
        )

    text = request.text.strip()

    if not text:
        raise HTTPException(
            status_code=422,
            detail="Please enter some text.",
        )

    try:
        inputs = tokenizer(
            text,
            return_tensors="pt",
            truncation=True,
            max_length=512,
            padding=True,
        )

        inputs = {
            key: value.to(device)
            for key, value in inputs.items()
        }

        with torch.inference_mode():
            outputs = model(**inputs)
            probabilities = torch.softmax(
                outputs.logits,
                dim=-1,
            )[0]

        predicted_id = int(torch.argmax(probabilities).item())

        scores = {
            id2label[i]: round(float(score.item()), 6)
            for i, score in enumerate(probabilities)
        }

        return {
            "success": True,
            "model": "DistilBERT",
            "emotion": id2label[predicted_id],
            "confidence": round(
                float(probabilities[predicted_id].item()),
                6,
            ),
            "scores": scores,
        }

    except Exception as exc:
        print("Text emotion prediction failed:", repr(exc))
        raise HTTPException(
            status_code=500,
            detail="Unable to analyze the text.",
        ) from exc


@app.post("/predict/voice-emotion")
async def predict_voice_emotion_endpoint(
        file: UploadFile = File(...),
        language: str = Form(...),
):
    """Predict emotion from an uploaded audio recording."""

    if not voice_models_loaded:
        raise HTTPException(
            status_code=503,
            detail="Voice emotion models are not loaded.",
        )

    language = language.strip().lower()

    if language not in ("english", "urdu"):
        raise HTTPException(
            status_code=400,
            detail="Language must be 'english' or 'urdu'.",
        )

    try:
        audio_bytes = await file.read(MAX_AUDIO_SIZE + 1)

        if not audio_bytes:
            raise HTTPException(
                status_code=400,
                detail="The uploaded audio file is empty.",
            )

        if len(audio_bytes) > MAX_AUDIO_SIZE:
            raise HTTPException(
                status_code=413,
                detail="Audio file must not exceed 25 MB.",
            )

        result = predict_voice_emotion(
            audio_bytes=audio_bytes,
            language=language,
        )

        return result

    except HTTPException:
        raise
    except ValueError as exc:
        raise HTTPException(
            status_code=400,
            detail=str(exc),
        ) from exc
    except Exception as exc:
        print("Voice emotion prediction failed:", repr(exc))
        raise HTTPException(
            status_code=500,
            detail="Unable to analyze the audio. Please try another recording.",
        ) from exc
    finally:
        await file.close()
