import torch
import librosa
from transformers import AutoModelForAudioClassification, AutoFeatureExtractor

def predict_emotion(audio_path):
    model_path = "./"
    print("Loading model...")
    model = AutoModelForAudioClassification.from_pretrained(model_path)
    feature_extractor = AutoFeatureExtractor.from_pretrained(model_path)
    model.eval()

    print(f"Processing audio: {audio_path}")
    speech_array, sampling_rate = librosa.load(audio_path, sr=16000)
    
    inputs = feature_extractor(
        speech_array, 
        sampling_rate=16000, 
        return_tensors="pt", 
        padding=True
    )

    with torch.no_grad():
        logits = model(**inputs).logits
        probabilities = torch.nn.functional.softmax(logits, dim=-1)

    predicted_id = torch.argmax(logits, dim=-1).item()
    predicted_label = model.config.id2label[predicted_id]
    confidence = probabilities[0][predicted_id].item() * 100

    print(f"🎯 Predicted Emotion: {predicted_label.upper()} (Confidence: {confidence:.2f}%)")
    return predicted_label, confidence

if __name__ == "__main__":
    # Yahan apni audio file ka naam dein jab local PC par run karein
    audio_file = input("Enter path to your .wav audio file: ")
    predict_emotion(audio_file)
