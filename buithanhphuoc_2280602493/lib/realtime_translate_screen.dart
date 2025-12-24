import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class RealtimeTranslateScreen extends StatefulWidget {
  const RealtimeTranslateScreen({super.key});

  @override
  State<RealtimeTranslateScreen> createState() =>
      _RealtimeTranslateScreenState();
}

class _RealtimeTranslateScreenState extends State<RealtimeTranslateScreen> {
  CameraController? _cameraController;
  bool _isDetecting = false;
  bool _isCameraInitialized = false;
  String _recognizedText = '';
  String _translatedText = '';
  bool _isTranslating = false;
  Timer? _translationTimer;

  TranslateLanguage _sourceLanguage = TranslateLanguage.english;
  TranslateLanguage _targetLanguage = TranslateLanguage.vietnamese;
  OnDeviceTranslator? _translator;

  final Map<TranslateLanguage, String> _languageNames = {
    TranslateLanguage.vietnamese: 'Tiếng Việt',
    TranslateLanguage.english: 'English',
    TranslateLanguage.chinese: '中文',
    TranslateLanguage.japanese: '日本語',
    TranslateLanguage.korean: '한국어',
    TranslateLanguage.french: 'Français',
    TranslateLanguage.german: 'Deutsch',
    TranslateLanguage.spanish: 'Español',
  };

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initTranslator();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không tìm thấy camera')),
          );
        }
        return;
      }

      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
        _startImageStream();
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  void _initTranslator() {
    _translator = OnDeviceTranslator(
      sourceLanguage: _sourceLanguage,
      targetLanguage: _targetLanguage,
    );
  }

  void _startImageStream() {
    // Capture frames periodically instead of streaming
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!_isDetecting && _isCameraInitialized) {
        await _captureAndDetectText();
      }
    });
  }

  Future<void> _captureAndDetectText() async {
    if (!_isCameraInitialized || _isDetecting) return;

    try {
      _isDetecting = true;

      // Capture image from camera
      final XFile imageFile = await _cameraController!.takePicture();

      // Create InputImage from file
      final inputImage = InputImage.fromFilePath(imageFile.path);

      // Recognize text
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      await textRecognizer.close();

      if (recognizedText.text.isNotEmpty &&
          recognizedText.text != _recognizedText) {
        setState(() {
          _recognizedText = recognizedText.text;
        });

        // Debounce translation - chỉ dịch sau 1 giây không có thay đổi
        _translationTimer?.cancel();
        _translationTimer = Timer(const Duration(milliseconds: 1000), () {
          _translateText(_recognizedText);
        });
      }
    } catch (e) {
      debugPrint('Error detecting text: $e');
    } finally {
      _isDetecting = false;
    }
  }

  Future<void> _translateText(String text) async {
    if (text.isEmpty || _isTranslating) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      final result = await _translator!.translateText(text);
      if (mounted) {
        setState(() {
          _translatedText = result;
          _isTranslating = false;
        });
      }
    } catch (e) {
      debugPrint('Error translating: $e');
      setState(() {
        _isTranslating = false;
      });
    }
  }

  Future<void> _changeLanguages(
    TranslateLanguage? source,
    TranslateLanguage? target,
  ) async {
    if (source != null) _sourceLanguage = source;
    if (target != null) _targetLanguage = target;

    await _translator?.close();
    _translator = OnDeviceTranslator(
      sourceLanguage: _sourceLanguage,
      targetLanguage: _targetLanguage,
    );

    setState(() {
      _translatedText = '';
    });

    // Dịch lại văn bản hiện tại với ngôn ngữ mới
    if (_recognizedText.isNotEmpty) {
      _translateText(_recognizedText);
    }
  }

  @override
  void dispose() {
    _translationTimer?.cancel();
    _cameraController?.dispose();
    _translator?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dịch Realtime',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: !_isCameraInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Language selector
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildLanguageDropdown(
                          value: _sourceLanguage,
                          onChanged: (value) => _changeLanguages(value, null),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.deepPurple.shade700,
                        ),
                      ),
                      Expanded(
                        child: _buildLanguageDropdown(
                          value: _targetLanguage,
                          onChanged: (value) => _changeLanguages(null, value),
                        ),
                      ),
                    ],
                  ),
                ),

                // Camera preview with overlay translation
                Expanded(
                  child: Stack(
                    children: [
                      // Camera preview
                      SizedBox.expand(child: CameraPreview(_cameraController!)),

                      // Overlay guide frame
                      if (_recognizedText.isEmpty)
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.85,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Đưa văn bản vào khung này',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Translation overlay (appears when text is detected)
                      if (_recognizedText.isNotEmpty)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.5,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.3),
                                  Colors.black.withOpacity(0.85),
                                ],
                              ),
                            ),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Recognized text section (smaller, less prominent)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.text_fields,
                                          color: Colors.white.withOpacity(0.7),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _recognizedText,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Translated text section (larger, prominent)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.green.withOpacity(0.5),
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.translate,
                                              color: Colors.greenAccent,
                                              size: 22,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Bản dịch:',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.greenAccent,
                                              ),
                                            ),
                                            if (_isTranslating) ...[
                                              const SizedBox(width: 8),
                                              SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.greenAccent),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _translatedText.isEmpty
                                              ? 'Đang dịch...'
                                              : _translatedText,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            height: 1.5,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(
                                                  0.5,
                                                ),
                                                blurRadius: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLanguageDropdown({
    required TranslateLanguage value,
    required ValueChanged<TranslateLanguage?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.deepPurple.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TranslateLanguage>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.deepPurple.shade700),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.deepPurple.shade900,
          ),
          items: _languageNames.entries.map((entry) {
            return DropdownMenuItem<TranslateLanguage>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
