import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart'; // Cần import để dùng SpeechRecognitionResult

class VoiceInputButton extends StatefulWidget {
  // Hàm callback để gửi lệnh đã nhận diện về màn hình cha
  final Function(String command) onCommand;

  const VoiceInputButton({required this.onCommand, super.key});

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  // Sửa lỗi: Thêm final vì biến này không thay đổi
  final String _currentLocaleId = 'vi_VN'; // Ngôn ngữ Tiếng Việt

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  // Hàm khởi tạo Mic
  Future<bool> _initSpeech() async {
    bool isAvailable = false;
    try {
      isAvailable = await _speechToText.initialize(
        onError: (e) {
          debugPrint('STT Lỗi khởi tạo: $e'); // Sửa lỗi: Dùng debugPrint thay vì print
        },
        onStatus: (status) {
          debugPrint('STT Trạng thái: $status');
        },
      );
    } catch (e) {
      debugPrint('STT Exception: $e');
    }

    if (mounted) {
      setState(() {
        _speechEnabled = isAvailable;
      });
    }
    return isAvailable;
  }

  // Hàm bắt đầu nghe
  void _startListening() async {
    if (!_speechEnabled) {
      // Thử khởi tạo lại nếu chưa sẵn sàng
      _speechEnabled = await _initSpeech();
    }

    if (_speechEnabled && !_speechToText.isListening) {
      await _speechToText.listen(
        // Sửa lỗi: Khai báo rõ kiểu dữ liệu kết quả
        onResult: (SpeechRecognitionResult result) {
          _onSpeechResult(result);
        },
        localeId: _currentLocaleId,
        listenFor: const Duration(seconds: 5),
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      );
    } else if (!_speechEnabled) {
      // Sửa lỗi: Kiểm tra mounted trước khi dùng context
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi: Không thể kích hoạt Micro. Vui lòng cấp quyền.')),
        );
      }
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  // Hàm dừng nghe
  void _stopListening() async {
    await _speechToText.stop();
    if (mounted) {
      setState(() {});
    }
  }

  // Xử lý kết quả trả về
  void _onSpeechResult(SpeechRecognitionResult result) {
    // Chỉ xử lý khi kết quả đã chốt (finalResult) hoặc khi đang nhận diện (nếu muốn realtime)
    // Ở đây ta dùng finalResult để lấy câu hoàn chỉnh
    if (result.finalResult) {
      final String command = result.recognizedWords;
      widget.onCommand(command);

      // Hiển thị thông báo (SnackBar)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã nhận lệnh: "$command"'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating, // Nổi lên trên cho đẹp
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Luôn hiển thị nút nhưng đổi màu xám nếu Mic hỏng (để người dùng biết sự tồn tại của nút)
    final bool isListening = _speechToText.isListening;
    final bool isReady = _speechEnabled;

    return FloatingActionButton(
      heroTag: "voiceBtnUnique", // Đặt tag duy nhất tránh lỗi
      onPressed: isReady 
          ? (isListening ? _stopListening : _startListening) 
          : _initSpeech, // Nếu chưa sẵn sàng thì bấm vào sẽ thử init lại
      tooltip: 'Điều khiển bằng giọng nói',
      backgroundColor: isReady 
          ? (isListening ? Colors.red.shade700 : Colors.blue.shade600) 
          : Colors.grey, // Màu xám nếu lỗi mic
      child: Icon(isListening ? Icons.mic_off : Icons.mic),
    );
  }
}