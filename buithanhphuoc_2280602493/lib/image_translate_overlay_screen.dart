import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class ImageTranslateOverlayScreen extends StatefulWidget {
  final String imagePath;
  final TranslateLanguage sourceLanguage;
  final TranslateLanguage targetLanguage;

  const ImageTranslateOverlayScreen({
    super.key,
    required this.imagePath,
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  @override
  State<ImageTranslateOverlayScreen> createState() =>
      _ImageTranslateOverlayScreenState();
}

class TextBlockTranslation {
  final Rect boundingBox;
  final String originalText;
  final String translatedText;

  TextBlockTranslation({
    required this.boundingBox,
    required this.originalText,
    required this.translatedText,
  });
}

class _ImageTranslateOverlayScreenState
    extends State<ImageTranslateOverlayScreen> {
  bool _isProcessing = true;
  OnDeviceTranslator? _translator;

  ui.Image? _image;
  Size _imageSize = Size.zero;
  List<TextBlockTranslation> _textBlocks = [];

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      // ------------ Load image for dimension info ------------
      final file = File(widget.imagePath);
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();

      _image = frame.image;
      _imageSize = Size(_image!.width.toDouble(), _image!.height.toDouble());

      // ------------ Step 1: OCR ------------
      final inputImage = InputImage.fromFilePath(widget.imagePath);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);

      await textRecognizer.close();

      if (recognizedText.blocks.isEmpty) {
        setState(() => _isProcessing = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không tìm thấy văn bản trong ảnh'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // ------------ Step 2: Translate blocks ------------
      _translator = OnDeviceTranslator(
        sourceLanguage: widget.sourceLanguage,
        targetLanguage: widget.targetLanguage,
      );

      final List<TextBlockTranslation> results = [];

      for (var block in recognizedText.blocks) {
        try {
          final translated = await _translator!.translateText(block.text);

          results.add(
            TextBlockTranslation(
              boundingBox: block.boundingBox,
              originalText: block.text,
              translatedText: translated,
            ),
          );
        } catch (e) {
          debugPrint("Error translating block: $e");
        }
      }

      setState(() {
        _textBlocks = results;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _translator?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text(
          'Dịch từ Ảnh',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: _isProcessing
          ? _buildProcessing()
          : Stack(
              children: [
                Center(
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                  ),
                ),

                if (_textBlocks.isNotEmpty)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: TranslationOverlayPainter(
                          textBlocks: _textBlocks,
                          imageSize: _imageSize,
                          containerSize: Size(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
    );
  }

  Widget _buildProcessing() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            SizedBox(height: 20),
            Text(
              'Đang nhận dạng và dịch...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TranslationOverlayPainter extends CustomPainter {
  final List<TextBlockTranslation> textBlocks;
  final Size imageSize;
  final Size containerSize;

  TranslationOverlayPainter({
    required this.textBlocks,
    required this.imageSize,
    required this.containerSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = containerSize.width / imageSize.width;
    final scaleY = containerSize.height / imageSize.height;
    final scale = (scaleX < scaleY) ? scaleX : scaleY;

    final scaledWidth = imageSize.width * scale;
    final scaledHeight = imageSize.height * scale;

    final offsetX = (containerSize.width - scaledWidth) / 2;
    final offsetY = (containerSize.height - scaledHeight) / 2;

    for (var block in textBlocks) {
      final rect = Rect.fromLTWH(
        offsetX + block.boundingBox.left * scale,
        offsetY + block.boundingBox.top * scale,
        block.boundingBox.width * scale,
        block.boundingBox.height * scale,
      );

      // Background
      final bg = Paint()
        ..color = Colors.black.withOpacity(0.85)
        ..style = PaintingStyle.fill;

      canvas.drawRect(rect, bg);

      // Border
      final border = Paint()
        ..color = Colors.greenAccent.withOpacity(0.9)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawRect(rect, border);

      // Text painter
      final painter = TextPainter(
        text: TextSpan(
          text: block.translatedText,
          style: TextStyle(
            color: Colors.white,
            fontSize: _fontSize(rect.height),
            fontWeight: FontWeight.bold,
            height: 1.2,
            shadows: const [
              Shadow(
                color: Colors.black,
                blurRadius: 4,
              ),
            ],
          ),
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );

      painter.layout(maxWidth: rect.width - 10);

      final offset = Offset(
        rect.left + 5,
        rect.top + (rect.height - painter.height) / 2,
      );

      painter.paint(canvas, offset);
    }
  }

  double _fontSize(double h) {
    if (h < 28) return 10;
    if (h < 45) return 12;
    if (h < 70) return 14;
    if (h < 110) return 16;
    return 18;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
