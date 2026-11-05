
from io import BytesIO
from pathlib import Path

import torch
from PIL import Image, ImageOps, UnidentifiedImageError
from transformers import ViTForImageClassification, ViTImageProcessor


# --------------------------------------------------
# Configuration
# --------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent.parent

MODEL_DIR = BASE_DIR / "models" / "facial_emotion_vit"

MAX_IMAGE_BYTES = 10 * 1024 * 1024

DEVICE = torch.device("cpu")

_vit_model = None
_vit_processor = None
CLASS_NAMES = {}


# --------------------------------------------------
# Load ViT model
# --------------------------------------------------

def load_facial_vit_model():
    global _vit_model, _vit_processor, CLASS_NAMES

    if not MODEL_DIR.is_dir():
        raise FileNotFoundError(
            f"ViT facial emotion model folder not found: {MODEL_DIR}"
        )

    config_path = MODEL_DIR / "config.json"
    weights_path = MODEL_DIR / "model.safetensors"
    processor_path = MODEL_DIR / "preprocessor_config.json"

    for path in (config_path, weights_path, processor_path):
        if not path.exists():
            raise FileNotFoundError(
                f"Required ViT model file not found: {path}"
            )

    processor = ViTImageProcessor.from_pretrained(
        str(MODEL_DIR),
        local_files_only=True,
    )

    model = ViTForImageClassification.from_pretrained(
        str(MODEL_DIR),
        local_files_only=True,
        use_safetensors=True,
    )

    model.to(DEVICE)
    model.eval()

    labels = {
        int(key): value
        for key, value in model.config.id2label.items()
    }

    expected_labels = {
        0: "Angry",
        1: "Happy",
        2: "Sad",
        3: "Neutral",
    }

    if labels != expected_labels:
        raise ValueError(
            f"Unexpected ViT emotion labels: {labels}"
        )

    if model.config.num_labels != 4:
        raise ValueError(
            f"Expected 4 emotion classes, "
            f"but model has {model.config.num_labels}."
        )

    _vit_processor = processor
    _vit_model = model
    CLASS_NAMES = labels

    print("MindMate ViT facial emotion model loaded.")
    print("ViT emotion labels:", CLASS_NAMES)


# --------------------------------------------------
# Predict facial emotion
# --------------------------------------------------

def predict_facial_emotion_vit(image_bytes: bytes) -> dict:
    if _vit_model is None or _vit_processor is None:
        raise RuntimeError(
            "ViT facial emotion model has not been loaded."
        )

    if not image_bytes:
        raise ValueError("The uploaded image is empty.")

    if len(image_bytes) > MAX_IMAGE_BYTES:
        raise ValueError("Image exceeds the 10 MB limit.")

    try:
        with Image.open(BytesIO(image_bytes)) as image:
            image = ImageOps.exif_transpose(image)
            image = image.convert("RGB")

            inputs = _vit_processor(
                images=image,
                return_tensors="pt",
            )

    except (
            UnidentifiedImageError,
            OSError,
            ValueError,
    ) as exc:
        raise ValueError(
            "Please upload a valid image."
        ) from exc

    inputs = {
        key: value.to(DEVICE)
        for key, value in inputs.items()
    }

    with torch.inference_mode():
        outputs = _vit_model(**inputs)

        probabilities = torch.softmax(
            outputs.logits,
            dim=-1,
        )[0]

    predicted_index = int(
        torch.argmax(probabilities).item()
    )

    scores = {
        CLASS_NAMES[index]: round(
            float(probabilities[index].item()),
            6,
        )
        for index in range(len(CLASS_NAMES))
    }

    return {
        "success": True,
        "model": "ViT_Facial_Emotion_4Class",
        "emotion": CLASS_NAMES[predicted_index],
        "confidence": round(
            float(probabilities[predicted_index].item()),
            6,
        ),
        "scores": scores,
    }
