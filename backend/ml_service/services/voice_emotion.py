
from io import BytesIO
from pathlib import Path

import librosa
import torch
from transformers import (
    AutoFeatureExtractor,
    AutoModelForAudioClassification,
)

BASE_DIR = Path(__file__).resolve().parents[1]
MODELS_DIR = BASE_DIR / "models"

MODEL_PATHS = {
    "english": MODELS_DIR / "voice_emotion_english",
    "urdu": MODELS_DIR / "voice_emotion_urdu",
}

SAMPLE_RATE = 16000
DEVICE = torch.device("cpu")

# Models are loaded once and reused for subsequent predictions.
_voice_models = {}


def load_voice_models():
    """Load both voice emotion models and their own feature extractors."""
    global _voice_models

    loaded_models = {}

    for language, model_path in MODEL_PATHS.items():
        if not model_path.is_dir():
            raise RuntimeError(
                f"{language.title()} voice model folder not found: "
                f"{model_path}"
            )

        if not (model_path / "config.json").is_file():
            raise RuntimeError(
                f"Missing config.json in {model_path}"
            )

        if not (model_path / "model.safetensors").is_file():
            raise RuntimeError(
                f"Missing model.safetensors in {model_path}"
            )

        print(f"Loading {language} voice emotion model...")

        feature_extractor = AutoFeatureExtractor.from_pretrained(
            str(model_path),
            local_files_only=True,
        )

        model = AutoModelForAudioClassification.from_pretrained(
            str(model_path),
            local_files_only=True,
            use_safetensors=True,
        )

        model.to(DEVICE)
        model.eval()

        labels = {
            int(key): value
            for key, value in model.config.id2label.items()
        }

        if not labels:
            raise RuntimeError(
                f"No emotion labels found for {language} model."
            )

        loaded_models[language] = {
            "model": model,
            "feature_extractor": feature_extractor,
            "labels": labels,
        }

        print(f"{language.title()} labels: {labels}")

    _voice_models = loaded_models
    print("MindMate voice emotion models loaded successfully.")


def predict_voice_emotion(audio_bytes: bytes, language: str):
    """Predict voice emotion from uploaded audio bytes."""
    language = language.strip().lower()

    if language not in MODEL_PATHS:
        raise ValueError("Language must be 'english' or 'urdu'.")

    if not audio_bytes:
        raise ValueError("The uploaded audio file is empty.")

    if language not in _voice_models:
        raise RuntimeError(
            "Voice emotion models are not loaded."
        )

    try:
        audio, _ = librosa.load(
            BytesIO(audio_bytes),
            sr=SAMPLE_RATE,
            mono=True,
        )

        if audio.size == 0:
            raise ValueError("The audio contains no usable samples.")

        if not torch.isfinite(torch.from_numpy(audio)).all():
            raise ValueError("The audio contains invalid sample values.")

        entry = _voice_models[language]

        inputs = entry["feature_extractor"](
            audio,
            sampling_rate=SAMPLE_RATE,
            return_tensors="pt",
            padding=True,
        )

        inputs = {
            key: value.to(DEVICE)
            for key, value in inputs.items()
        }

        with torch.inference_mode():
            logits = entry["model"](**inputs).logits
            probabilities = torch.softmax(logits, dim=-1)[0]

        predicted_id = int(torch.argmax(probabilities).item())
        labels = entry["labels"]

        if predicted_id not in labels:
            raise RuntimeError(
                "The model returned an unknown emotion label."
            )

        scores = {
            labels[index]: round(float(score.item()), 6)
            for index, score in enumerate(probabilities)
            if index in labels
        }

        return {
            "success": True,
            "model": f"Wav2Vec2-{language}",
            "language": language,
            "emotion": labels[predicted_id],
            "confidence": round(
                float(probabilities[predicted_id].item()), 6
            ),
            "scores": scores,
        }

    except (ValueError, RuntimeError):
        raise
    except Exception as exc:
        import traceback

    traceback.print_exc()

    raise HTTPException(
        status_code=500,
        detail="Unable to analyze the audio. Please try another recording."
    ) from exc
