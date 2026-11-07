ENGLISH SPEECH EMOTION RECOGNITION
==================================

MODEL:
Wav2Vec2 XLSR

PRETRAINED MODEL:
ehcalabres/wav2vec2-lg-xlsr-en-speech-emotion-recognition

DATASET:
AbstractTTS/TESS

FINE-TUNING:
Pretrained model fine-tuned on selected TESS emotions.

SUPPORTED EMOTIONS:
1. Angry
2. Happy
3. Neutral
4. Sad

MODEL SETTINGS:
Sampling Rate: 16000 Hz
Framework: PyTorch
Number of Classes: 4

FINAL EVALUATION:
Training, Validation and Testing metrics are saved
in metrics.json and final_performance.csv.

DATA SPLIT:
Training and Validation: OAF speaker
Testing: YAF speaker

IMPORTANT:
The test set contains a held-out speaker.
Results on acted TESS speech do not guarantee
the same performance on natural real-world speech.

INTEGRATION:
best_model.pth contains model weights.
The same custom Wav2Vec2 classification architecture
used during training must be recreated before loading
these weights.

Load the feature extractor from the feature_extractor
directory using AutoFeatureExtractor.from_pretrained().

Use label_mapping.json for correct emotion mapping.
Use preprocessing_config.json for audio settings.