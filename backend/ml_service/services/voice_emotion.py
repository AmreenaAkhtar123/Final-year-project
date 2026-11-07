
from io import BytesIO
from pathlib import Path
import json
import traceback

import librosa
import numpy as np
import torch
import torch.nn as nn

from fastapi import HTTPException
from transformers import (
    AutoFeatureExtractor,
    AutoModelForAudioClassification,
    Wav2Vec2Config,
    Wav2Vec2Model,
)


BASE_DIR = Path(__file__).resolve().parents[1]
MODELS_DIR = BASE_DIR / "models"

MODEL_PATHS = {
    "english": MODELS_DIR / "voice_emotion_english_new",
    "urdu": MODELS_DIR / "voice_emotion_urdu_new",
}

SAMPLE_RATE = 16000
DEVICE = torch.device("cpu")

_voice_models = {}


# --------------------------------------------------
# English custom classification architecture
# --------------------------------------------------

class EnglishVoiceEmotionModel(nn.Module):
    def __init__(self, config):
        super().__init__()

        self.wav2vec2 = Wav2Vec2Model(config)

        self.classifier = nn.Module()
        self.classifier.dense = nn.Linear(
            config.hidden_size,
            config.hidden_size,
        )
        self.classifier.output = nn.Linear(
            config.hidden_size,
            8,
        )

    def forward(self, input_values, attention_mask=None):
        outputs = self.wav2vec2(
            input_values=input_values,
            attention_mask=attention_mask,
        )

        hidden_states = outputs.last_hidden_state

        # Mean pooling over valid audio frames.
        if attention_mask is not None:
            feature_mask = self.wav2vec2._get_feature_vector_attention_mask(
                hidden_states.shape[1],
                attention_mask,
            )

            mask = feature_mask.unsqueeze(-1).to(hidden_states.dtype)

            pooled_output = (
                    (hidden_states * mask).sum(dim=1)
                    / mask.sum(dim=1).clamp(min=1)
            )
        else:
            pooled_output = hidden_states.mean(dim=1)

        # Assumption: tanh activation.
        # Original training code was unavailable, so this
        # activation has not been independently verified.
        pooled_output = torch.tanh(
            self.classifier.dense(pooled_output)
        )

        logits = self.classifier.output(pooled_output)

        return logits


# --------------------------------------------------
# Load English model
# --------------------------------------------------

def load_english_model(model_path):
    checkpoint_path = model_path / "best_model.pth"

    if not checkpoint_path.is_file():
        raise RuntimeError(
            f"English checkpoint not found: {checkpoint_path}"
        )

    print("Loading English feature extractor...")

    feature_extractor = AutoFeatureExtractor.from_pretrained(
        str(model_path),
        local_files_only=True,
    )

    print("Loading English configuration...")

    config = Wav2Vec2Config.from_pretrained(
        str(model_path),
        local_files_only=True,
    )

    model = EnglishVoiceEmotionModel(config)

    print("Reading English checkpoint...")

    state_dict = torch.load(
        checkpoint_path,
        map_location="cpu",
        weights_only=True,
    )

    backbone_state = {
        key.replace("wav2vec2.", "", 1): value
        for key, value in state_dict.items()
        if key.startswith("wav2vec2.")
    }

    classifier_state = {
        key.replace("classifier.", "", 1): value
        for key, value in state_dict.items()
        if key.startswith("classifier.")
    }

    # Load the Wav2Vec2 backbone.
    model.wav2vec2.load_state_dict(
        backbone_state,
        strict=True,
    )

    # Load the custom classification head.
    model.classifier.load_state_dict(
        classifier_state,
        strict=True,
    )

    model.to(DEVICE)
    model.eval()

    # Read original emotion class mapping.
    with open(
            model_path / "label_mapping.json",
            "r",
            encoding="utf-8",
    ) as file:
        label_mapping = json.load(file)

    output_mapping = label_mapping[
        "output_index_to_original_model_class_id"
    ]

    # Select the original eight-class output positions:
    # 0 = Angry, 4 = Happy, 5 = Neutral, 6 = Sad.
    selected_indices = [
        int(original_class_id)
        for _, original_class_id in sorted(
            output_mapping.items(),
            key=lambda item: int(item[0]),
        )
    ]

    original_labels = label_mapping[
        "original_model_class_id_to_emotion"
    ]

    # IMPORTANT:
    # After selecting four logits and applying softmax,
    # their new positions are 0, 1, 2, and 3.
    labels = {
        output_index: original_labels[str(original_class_id)]
        for output_index, original_class_id in enumerate(
            selected_indices
        )
    }

    if len(selected_indices) != 4 or len(labels) != 4:
        raise RuntimeError(
            "English model must have four supported emotion classes."
        )

    print("English model loaded successfully.")
    print("English selected original indices:", selected_indices)
    print("English emotions:", labels)

    return {
        "model": model,
        "feature_extractor": feature_extractor,
        "labels": labels,
        "selected_indices": selected_indices,
    }


# --------------------------------------------------
# Load Urdu model
# --------------------------------------------------

def load_urdu_model(model_path):
    if not (model_path / "model.safetensors").is_file():
        raise RuntimeError(
            f"Urdu model.safetensors not found in {model_path}"
        )

    print("Loading Urdu feature extractor...")

    feature_extractor = AutoFeatureExtractor.from_pretrained(
        str(model_path),
        local_files_only=True,
    )

    print("Loading Urdu classification model...")

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
            "No emotion labels found for Urdu model."
        )

    print("Urdu model loaded successfully.")
    print("Urdu emotions:", labels)

    return {
        "model": model,
        "feature_extractor": feature_extractor,
        "labels": labels,
    }


# --------------------------------------------------
# Load both voice models
# --------------------------------------------------

def load_voice_models():
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

        print(f"\nLoading {language} voice emotion model...")

        if language == "english":
            loaded_models[language] = load_english_model(
                model_path
            )

        elif language == "urdu":
            loaded_models[language] = load_urdu_model(
                model_path
            )

    _voice_models = loaded_models

    print("\nMindMate voice emotion models loaded successfully.")


# --------------------------------------------------
# Predict voice emotion
# --------------------------------------------------

def predict_voice_emotion(audio_bytes: bytes, language: str):

    language = language.strip().lower()

    if language not in MODEL_PATHS:
        raise ValueError(
            "Language must be 'english' or 'urdu'."
        )

    if not audio_bytes:
        raise ValueError(
            "The uploaded audio file is empty."
        )

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
            raise ValueError(
                "The audio contains no usable samples."
            )

        if not np.isfinite(audio).all():
            raise ValueError(
                "The audio contains invalid sample values."
            )

        entry = _voice_models[language]

        if language == "urdu":
            print("\n========== URDU AUDIO INSPECTION ==========")
            print("Audio samples:", len(audio))
            print("Duration:", round(len(audio) / SAMPLE_RATE, 2))
            print("Minimum:", float(np.min(audio)))
            print("Maximum:", float(np.max(audio)))
            print("Mean:", float(np.mean(audio)))
            print("Standard deviation:", float(np.std(audio)))
            print("Feature extractor normalization:",
                  entry["feature_extractor"].do_normalize)
            print("===========================================\n")

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

            logits = entry["model"](**inputs)

            if language == "english":

                # English checkpoint produces eight logits.
                # Keep only Angry, Happy, Neutral, and Sad.
                selected_indices = entry["selected_indices"]

                selected_logits = logits[:, selected_indices]

                probabilities = torch.softmax(
                    selected_logits,
                    dim=-1,
                )[0]

            else:
                # Urdu model directly produces four logits.
                probabilities = torch.softmax(
                    logits.logits,
                    dim=-1,
                )[0]

        predicted_id = int(
            torch.argmax(probabilities).item()
        )

        labels = entry["labels"]

        if predicted_id not in labels:
            raise RuntimeError(
                f"Unknown emotion label index: {predicted_id}. "
                f"Available labels: {labels}"
            )

        scores = {
            labels[index]: round(float(score.item()), 6)
            for index, score in enumerate(probabilities)
        }
        if language == "urdu":
            print("\n========== URDU VOICE DEBUG ==========")
            print("Raw logits:", logits.logits[0].cpu().tolist())
            print("Emotion scores:", scores)
            print("Predicted emotion:", labels[predicted_id])
            print(
                "Confidence:",
                round(float(probabilities[predicted_id].item()), 6),
            )
            print("Audio duration:", round(len(audio) / SAMPLE_RATE, 2), "seconds")
            print("Audio peak:", float(np.max(np.abs(audio))))
            print("======================================\n")



        return {
            "success": True,
            "model": f"Wav2Vec2-{language}",
            "language": language,
            "emotion": labels[predicted_id],
            "confidence": round(
                float(probabilities[predicted_id].item()),
                6,
            ),
            "scores": scores,
        }

    except (ValueError, RuntimeError):
        raise

    except Exception as exc:
        traceback.print_exc()

        raise HTTPException(
            status_code=500,
            detail=(
                "Unable to analyze the audio. "
                "Please try another recording."
            ),
        ) from exc
