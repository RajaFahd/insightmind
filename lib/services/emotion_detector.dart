import 'package:google_ml_kit/google_ml_kit.dart';
import '../utils/emotion_feedback.dart';

class EmotionDetector {
  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableTracking: true,
    ),
  );

  Future<void> initialize() async {
    // Initialization if needed
  }

  Future<Emotion?> detectEmotionFromInputImage(InputImage inputImage) async {
    try {
      final faces = await _faceDetector.processImage(inputImage);
      if (faces.isEmpty) return null;

      final face = faces.first; // Assume single face
      return _classifyEmotion(face);
    } catch (e) {
      return null;
    }
  }

  Emotion _classifyEmotion(Face face) {
    // Simple classification based on face features
    final smilingProbability = face.smilingProbability ?? 0.0;
    final leftEyeOpenProbability = face.leftEyeOpenProbability ?? 1.0;
    final rightEyeOpenProbability = face.rightEyeOpenProbability ?? 1.0;

    if (smilingProbability > 0.7) {
      return Emotion.happy;
    } else if (leftEyeOpenProbability < 0.5 && rightEyeOpenProbability < 0.5) {
      return Emotion.sad;
    } else if (smilingProbability < 0.3 && leftEyeOpenProbability > 0.8 && rightEyeOpenProbability > 0.8) {
      return Emotion.angry;
    } else if (leftEyeOpenProbability > 0.9 && rightEyeOpenProbability > 0.9 && smilingProbability < 0.5) {
      return Emotion.fearful;
    } else if (smilingProbability < 0.2 && leftEyeOpenProbability < 0.7 && rightEyeOpenProbability < 0.7) {
      return Emotion.surprised;
    } else {
      return Emotion.neutral;
    }
  }

  void dispose() {
    _faceDetector.close();
  }
}