import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart';

// --- IMPORT TẤT CẢ CÁC MÀN HÌNH CHỨC NĂNG ---
import 'package:buithanhphuoc_2280602493/stopwatch_screen.dart';
import 'package:buithanhphuoc_2280602493/alarm_screen.dart';
import 'package:buithanhphuoc_2280602493/temperature_converter_screen.dart';
import 'package:buithanhphuoc_2280602493/unit_converter_screen.dart'; 
import 'package:buithanhphuoc_2280602493/youtube_viewer_screen.dart';
import 'package:buithanhphuoc_2280602493/translate_screen.dart'; // [MỚI] Import màn hình Dịch

class VoiceCommanderScreen extends StatefulWidget {
  const VoiceCommanderScreen({super.key});

  @override
  State<VoiceCommanderScreen> createState() => _VoiceCommanderScreenState();
}

class _VoiceCommanderScreenState extends State<VoiceCommanderScreen> {
  final SpeechToText _speechToText = SpeechToText();
  final AudioPlayer player = AudioPlayer(); 
  
  bool _speechEnabled = false;
  String _currentLocaleId = 'vi_VN'; // Mặc định tiếng Việt
  String _lastCommand = "Đang chờ lệnh...";
  
  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  // Khởi tạo Speech-to-Text
  Future<bool> _initSpeech() async {
    bool isAvailable = false;
    try {
      isAvailable = await _speechToText.initialize(
        onError: (e) => debugPrint('STT Lỗi: $e'),
        onStatus: (s) => debugPrint('STT Trạng thái: $s'),
      );
    } catch (e) {
      debugPrint("STT Exception: $e");
    }

    if (mounted) {
      setState(() { _speechEnabled = isAvailable; });
    }
    return isAvailable; 
  }

  // Bắt đầu lắng nghe
  void _startListening() async {
    if (!_speechEnabled) { 
      _speechEnabled = await _initSpeech(); 
    }
    
    if (_speechEnabled && !_speechToText.isListening) {
      // Phát âm thanh nhẹ khi bắt đầu nghe (Optional)
      // await player.play(AssetSource('audio/ping.mp3')); 

      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: _currentLocaleId, 
        listenFor: const Duration(seconds: 5),
        cancelOnError: true,
      );
    } else if (!_speechEnabled && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không thể kích hoạt Micro. Hãy cấp quyền.')),
      );
    }
    setState(() {});
  }

  void _onSpeechResult(result) {
    if (result.finalResult) {
      final String command = result.recognizedWords;
      if (mounted) {
        _handleVoiceCommand(command);
      }
    }
  }

  // --- LOGIC XỬ LÝ LỆNH ĐIỀU HƯỚNG ---
  void _handleVoiceCommand(String command) {
    final lowerCaseCommand = command.toLowerCase();
    String action = "Lệnh không rõ ràng.";
    
    if (!mounted) return; 

    // Hàm điều hướng tiện ích
    void navigateTo(Widget screen, String screenName) {
      action = "Đang mở $screenName...";
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
    }

    // 1. Bấm giờ
    if (lowerCaseCommand.contains('bấm giờ') || lowerCaseCommand.contains('đồng hồ')) {
        navigateTo(const StopwatchScreen(), "Đồng hồ Bấm giờ");
    } 
    // 2. Báo thức
    else if (lowerCaseCommand.contains('báo thức') || lowerCaseCommand.contains('hẹn giờ')) {
        navigateTo(const AlarmScreen(), "Đồng hồ Báo thức");
    } 
    // 3. Nhiệt độ
    else if (lowerCaseCommand.contains('nhiệt độ') || lowerCaseCommand.contains('độ c')) {
        navigateTo(const TemperatureConverterScreen(), "Chuyển đổi Nhiệt độ");
    } 
    // 4. Đơn vị (Khối lượng/Độ dài)
    else if (lowerCaseCommand.contains('đơn vị') || 
             lowerCaseCommand.contains('khối lượng') || 
             lowerCaseCommand.contains('độ dài') ||
             lowerCaseCommand.contains('mét')) {
        navigateTo(const UnitConverterScreen(), "Chuyển đổi Đơn vị");
    }
    // 5. YouTube
    else if (lowerCaseCommand.contains('youtube') || lowerCaseCommand.contains('video') || lowerCaseCommand.contains('nhạc')) {
        navigateTo(const YoutubeViewerScreen(), "Xem Video YouTube");
    }
    // 6. [MỚI] Dịch thuật
    else if (lowerCaseCommand.contains('dịch') || 
             lowerCaseCommand.contains('phiên dịch') || 
             lowerCaseCommand.contains('translate') ||
             lowerCaseCommand.contains('ngoại ngữ')) {
        navigateTo(const TranslateScreen(), "Dịch Thuật Đa Năng");
    }
    // Lệnh không hiểu
    else {
        action = "Không hiểu lệnh: \"$command\"";
    }

    setState(() {
      _lastCommand = action;
    });
    
    // Hiển thị phản hồi lệnh
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(action),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      )
    );
  }

  @override
  void dispose() {
    _speechToText.stop();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isListening = _speechToText.isListening;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎤 Trợ Lý Giọng Nói'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        color: Colors.blue.shade50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon trạng thái động
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isListening ? 150 : 120,
              width: isListening ? 150 : 120,
              decoration: BoxDecoration(
                color: isListening ? Colors.red.shade100 : Colors.blue.shade100,
                shape: BoxShape.circle,
                boxShadow: [
                  if (isListening)
                    BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 30, spreadRadius: 10)
                ]
              ),
              child: Icon(
                isListening ? Icons.mic : Icons.mic_none,
                size: 60,
                color: isListening ? Colors.red : Colors.blue,
              ),
            ),
            
            const SizedBox(height: 40),
            
            const Text(
              'Nhấn nút bên dưới để ra lệnh',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 15),
            
            // Hộp hiển thị trạng thái lệnh
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  const Text("LỆNH GẦN NHẤT:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Text(
                    _lastCommand,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: _lastCommand.contains("Không hiểu") ? Colors.orange : Colors.blue.shade800
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            
            // Gợi ý câu lệnh
            const Text(
              'Gợi ý: "Mở dịch thuật", "Vào báo thức", "Xem Youtube"...',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
      
      // Nút bấm chính
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          heroTag: "voiceCommanderFab",
          onPressed: _startListening,
          backgroundColor: isListening ? Colors.red.shade600 : Colors.blue.shade700,
          elevation: 10,
          child: Icon(isListening ? Icons.stop : Icons.mic, size: 35),
        ),
      ),
    );
  }
}