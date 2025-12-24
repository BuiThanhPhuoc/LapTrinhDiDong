import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'realtime_translate_screen.dart';
import 'image_translate_overlay_screen.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  late stt.SpeechToText _speech;

  String _translatedText = '';
  bool _isListening = false;
  bool _isTranslating = false;
  bool _isRecognizing = false;

  TranslateLanguage _sourceLanguage = TranslateLanguage.vietnamese;
  TranslateLanguage _targetLanguage = TranslateLanguage.english;

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
    TranslateLanguage.thai: 'ไทย',
  };

  final Map<TranslateLanguage, String> _localeIds = {
    TranslateLanguage.vietnamese: 'vi_VN',
    TranslateLanguage.english: 'en_US',
    TranslateLanguage.chinese: 'zh_CN',
    TranslateLanguage.japanese: 'ja_JP',
    TranslateLanguage.korean: 'ko_KR',
    TranslateLanguage.french: 'fr_FR',
    TranslateLanguage.german: 'de_DE',
    TranslateLanguage.spanish: 'es_ES',
    TranslateLanguage.thai: 'th_TH',
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initTranslator();
  }

  Future<void> _initTranslator() async {
    await _translator?.close();
    _translator = OnDeviceTranslator(
      sourceLanguage: _sourceLanguage,
      targetLanguage: _targetLanguage,
    );
  }

  // 🔊 Speech To Text
  Future<void> _startListening() async {
    if (!_speech.isAvailable) {
      await _speech.initialize(
        onError: (e) => _showError("Lỗi mic: ${e.errorMsg}"),
        onStatus: (status) {
          if (status == "notListening") {
            setState(() => _isListening = false);
          }
        },
      );
    }

    if (!_speech.isAvailable) {
      return _showError("Thiết bị không hỗ trợ nhận diện giọng nói");
    }

    if (await Permission.microphone.isDenied) {
      if (await Permission.microphone.request().isDenied) {
        return _showError("Cần quyền Microphone");
      }
    }

    if (!_isListening) {
      setState(() => _isListening = true);
      _speech.listen(
        localeId: _localeIds[_sourceLanguage],
        partialResults: true,
        onResult: (result) {
          setState(() => _textController.text = result.recognizedWords);
        },
      );
    } else {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  // 📷 Chọn ảnh
  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      if (await Permission.camera.request().isDenied) {
        return _showError("Cần quyền Camera");
      }
    }

    setState(() => _isRecognizing = true);

    final file = await _imagePicker.pickImage(source: source);
    setState(() => _isRecognizing = false);

    if (file == null) return;

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageTranslateOverlayScreen(
          imagePath: file.path,
          sourceLanguage: _sourceLanguage,
          targetLanguage: _targetLanguage,
        ),
      ),
    );
  }

  // 🌀 Translate text
  Future<void> _translate() async {
    if (_textController.text.trim().isEmpty) {
      return _showError("Hãy nhập văn bản cần dịch");
    }

    setState(() {
      _isTranslating = true;
      _translatedText = "";
    });

    await _initTranslator();
    try {
      final result = await _translator!.translateText(_textController.text);
      setState(() {
        _translatedText = result;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() => _isTranslating = false);
      _showError("Lỗi dịch: $e");
    }
  }

  // 🔄 Swap language
  void _swapLanguages() async {
    final oldSource = _sourceLanguage;
    final oldText = _textController.text;

    setState(() {
      _sourceLanguage = _targetLanguage;
      _targetLanguage = oldSource;
      _textController.text = _translatedText;
      _translatedText = oldText;
    });

    await _initTranslator();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _translator?.close();
    _speech.stop();
    _textController.dispose();
    super.dispose();
  }

  // ---------------- UI BUILD ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dịch văn bản", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RealtimeTranslateScreen()));
            },
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            _buildLanguageSelector(),
            const SizedBox(height: 16),
            _buildInputCard(),
            const SizedBox(height: 16),
            _buildTranslateButton(),
            const SizedBox(height: 16),
            if (_translatedText.isNotEmpty) _buildOutputCard(),
          ],
        ),
      ),
    );
  }

  // ------------- UI COMPONENTS -------------

  Widget _buildLanguageSelector() {
    return Row(
      children: [
        Expanded(child: _dropdown(_sourceLanguage, (v) {
          setState(() {
            _sourceLanguage = v!;
            _translatedText = '';
          });
        })),

        IconButton(
          icon: const Icon(Icons.swap_horiz, size: 32),
          onPressed: _swapLanguages,
          color: Colors.blue,
        ),

        Expanded(child: _dropdown(_targetLanguage, (v) {
          setState(() {
            _targetLanguage = v!;
            _translatedText = '';
          });
        })),
      ],
    );
  }

  Widget _dropdown(TranslateLanguage value, ValueChanged<TranslateLanguage?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: value,
          isExpanded: true,
          items: _languageNames.entries.map((e) {
            return DropdownMenuItem(
              value: e.key,
              child: Text(e.value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Văn bản gốc",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.blue),
                      onPressed: () => _showImageDialog(),
                    ),
                    IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.red : Colors.blue,
                      ),
                      onPressed: _startListening,
                    ),
                  ],
                )
              ],
            ),

            TextField(
              controller: _textController,
              minLines: 3,
              maxLines: null,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: "Nhập nội dung cần dịch...",
              ),
            ),

            if (_isRecognizing)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(strokeWidth: 2),
                    SizedBox(width: 8),
                    Text("Đang nhận dạng ảnh..."),
                  ],
                ),
              ),

            if (_isListening)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Đang nghe..."),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Chọn nguồn ảnh"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Chụp ảnh"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Chọn từ thư viện"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.translate),
        label: Text(_isTranslating ? "Đang dịch..." : "Dịch"),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _isTranslating ? null : _translate,
      ),
    );
  }

  Widget _buildOutputCard() {
    return Card(
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Kết quả dịch",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: SelectableText(
                _translatedText,
                style: const TextStyle(fontSize: 18, height: 1.5),
              ),
            )
          ],
        ),
      ),
    );
  }
}
