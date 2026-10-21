
from io import BytesIO
from pathlib import Path

import numpy as np
import tensorflow as tf
from PIL import Image, ImageOps, UnidentifiedImageError


BASE_DIR = Path(__file__).resolve().parent.parent
MODEL_DIR = BASE_DIR / "models" / "facial_emotion"
MODEL_PATH = MODEL_DIR / "fast_emotion_7classes.keras"

# Provisional order from model_config.json.
# Verify against the original training code before relying on predictions.
CLASS_NAMES = [
    "angry",
    "disgust",
    "fear",
    "happy",
    "neutral",
    "sad",
    "surprise",
]

IMAGE_SIZE = (224, 224)
MAX_IMAGE_BYTES = 10 * 1024 * 1024

_facial_model = None


def load_facial_model():
    """Load the trained facial emotion classifier."""
    global _facial_model

    if not MODEL_PATH.exists():
        raise FileNotFoundError(
            f"Facial emotion model not found: {MODEL_PATH}"
        )

    model = tf.keras.models.load_model(
        MODEL_PATH,
        compile=False,
    )

    if model.output_shape[-1] != len(CLASS_NAMES):
        raise ValueError(
            f"Model outputs {model.output_shape[-1]} classes, "
            f"but CLASS_NAMES contains {len(CLASS_NAMES)} labels."
        )

    _facial_model = model
    print("Facial emotion model loaded successfully.")


def predict_facial_emotion(image_bytes: bytes) -> dict:
    """Predict facial-expression probabilities from an uploaded image."""
    if _facial_model is None:
        raise RuntimeError("Facial emotion model has not been loaded.")

    if not image_bytes:
        raise ValueError("The uploaded image is empty.")

    if len(image_bytes) > MAX_IMAGE_BYTES:
        raise ValueError("Image exceeds the 10 MB limit.")

    try:
        with Image.open(BytesIO(image_bytes)) as image:
            image = ImageOps.exif_transpose(image)
            image = image.convert("RGB")
            image = image.resize(IMAGE_SIZE)
            image_array = np.asarray(image, dtype=np.float32)

    except (UnidentifiedImageError, OSError, ValueError) as exc:
        raise ValueError("Please upload a valid image.") from exc

    # IMPORTANT:
    # This uses [0, 255] pixel values temporarily.
    # Change preprocessing only after confirming what was used in training.
    image_array = np.expand_dims(image_array, axis=0)

    probabilities = _facial_model.predict(
        image_array,
        verbose=0,
    )[0]

    predicted_index = int(np.argmax(probabilities))

    return {
        "success": True,
        "model": "MobileNetV2_FERPlus_7Class_Final",
        "emotion": CLASS_NAMES[predicted_index],
        "confidence": float(probabilities[predicted_index]),
        "scores": {
            name: float(probabilities[index])
            for index, name in enumerate(CLASS_NAMES)
        },
    }
