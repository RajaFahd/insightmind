import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:insightmind/services/emotion_detector.dart';
import 'package:insightmind/utils/emotion_feedback.dart';
import 'package:insightmind/theme.dart';

class EmotionalDetectorScreen extends StatefulWidget {
  static const routeName = '/emotional-detector';
  const EmotionalDetectorScreen({super.key});

  @override
  _EmotionalDetectorScreenState createState() => _EmotionalDetectorScreenState();
}

class _EmotionalDetectorScreenState extends State<EmotionalDetectorScreen> {
  CameraController? _cameraController;
  EmotionDetector? _emotionDetector;
  File? _capturedImage;
  Emotion? _detectedEmotion;
  String _status = "Siap untuk scan wajah";
  bool _isProcessing = false;
  bool _isInitialized = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        setState(() {
          _status = "Izin kamera ditolak. Gunakan galeri untuk memilih gambar.";
        });
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _status = "Kamera tidak tersedia. Gunakan galeri untuk memilih gambar.";
        });
        return;
      }

      _cameraController = CameraController(
        cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front),
        ResolutionPreset.medium,
      );

      await _cameraController!.initialize();
      _emotionDetector = EmotionDetector();
      await _emotionDetector!.initialize();

      setState(() {
        _isInitialized = true;
        _status = "Tekan tombol scan untuk mendeteksi emosi.";
      });
    } catch (e) {
      setState(() {
        _status = "Gagal menginisialisasi kamera: $e";
      });
    }
  }

  Future<void> _scanFace() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    setState(() {
      _isProcessing = true;
      _status = "Mengambil gambar...";
    });

    try {
      final image = await _cameraController!.takePicture();
      final file = File(image.path);
      setState(() {
        _capturedImage = file;
        _status = "Memproses gambar...";
      });

      await _processImage(file);
    } catch (e) {
      setState(() {
        _status = "Gagal mengambil gambar: $e";
        _isProcessing = false;
      });
    }
  }

  Future<void> _processImage(File image) async {
    if (_emotionDetector == null) return;

    try {
      final inputImage = InputImage.fromFile(image);
      final emotion = await _emotionDetector!.detectEmotionFromInputImage(inputImage);
      if (emotion != null) {
        setState(() {
          _detectedEmotion = emotion;
          _status = "Emosi terdeteksi! Konfirmasi hasil.";
        });
      } else {
        setState(() {
          _status = "Wajah tidak terdeteksi. Coba lagi.";
          _capturedImage = null;
        });
      }
    } catch (e) {
      setState(() {
        _status = "Error memproses gambar: $e";
        _capturedImage = null;
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _confirmResult() {
    if (_detectedEmotion != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Hasil Deteksi Emosi"),
          content: Text(EmotionFeedback.getFeedback(_detectedEmotion!)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _reset();
              },
              child: const Text("Scan Lagi"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _reset() {
    setState(() {
      _capturedImage = null;
      _detectedEmotion = null;
      _status = "Siap untuk scan wajah";
    });
  }

  void _pickFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        setState(() {
          _capturedImage = file;
          _status = "Memproses gambar dari galeri...";
          _isProcessing = true;
        });
        await _processImage(file);
      }
    } catch (e) {
      setState(() {
        _status = "Gagal memilih gambar: $e";
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _emotionDetector?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotional Detector'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _status,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.deepNavy),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Camera Preview or Captured Image
            Expanded(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _capturedImage != null
                      ? Image.file(_capturedImage!, fit: BoxFit.cover)
                      : _isInitialized
                          ? CameraPreview(_cameraController!)
                          : Center(
                              child: Text(
                                "Kamera tidak tersedia",
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.deepNavy),
                              ),
                            ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Buttons
            if (_detectedEmotion != null)
              ElevatedButton.icon(
                onPressed: _confirmResult,
                icon: const Icon(Icons.check),
                label: const Text("Lihat Hasil"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mint,
                  foregroundColor: AppColors.deepNavy,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            else if (!_isProcessing)
              Column(
                children: [
                  if (_isInitialized)
                    ElevatedButton.icon(
                      onPressed: _scanFace,
                      icon: const Icon(Icons.camera),
                      label: const Text("Scan Wajah"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.peach,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Pilih dari Galeri"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cream,
                      foregroundColor: AppColors.deepNavy,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: AppColors.peach),
                    ),
                  ),
                ],
              )
            else
              const CircularProgressIndicator(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}