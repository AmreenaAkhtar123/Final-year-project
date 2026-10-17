
from pathlib import Path

import torch
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from transformers import (
    AutoModelForSequenceClassification,
    AutoTokenizer,
)

BASE_DIR = Path(__file__).resolve().parent
MODEL_DIR = BASE_DIR / "models" / "text_emotion"

app = FastAPI(
    title="MindMate ML Service",
    version="1.0.0",
)

# Use CPU for the initial integration.
device = torch.device("cpu")

tokenizer = None
model = None
id2label = {}


@app.on_event("startup")
def load_model():
    global tokenizer, model, id2label

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
    print("Emotion labels:", id2label)


class PredictionRequest(BaseModel):
    text: str = Field(min_length=1, max_length=10000)


@app.get("/health")
def health():
    return {
        "status": "ok",
        "model_loaded": model is not None,
        "model_type": "DistilBERT",
    }


@app.post("/predict/text-emotion")
def predict_text_emotion(request: PredictionRequest):
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
