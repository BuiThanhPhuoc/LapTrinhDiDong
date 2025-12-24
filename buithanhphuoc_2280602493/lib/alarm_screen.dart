import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'voice_input_button.dart'; // Đảm bảo bạn đã có file này

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final AudioPlayer player = AudioPlayer();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isAlarmSet = false;
  Timer? _timer;
  
  // Biến hiển thị phản hồi giọng nói
  String _lastVoiceFeedback = "";

  @override
  void initState() {
    super.initState();
    // Cài đặt trước chế độ âm thanh
    player.setReleaseMode(ReleaseMode.loop);
    _startTimer();
  }

  // --- LOGIC HẸN GIỜ ---
  void _startTimer() {
    // Tối ưu: Chỉ cần check mỗi giây, không cần logic phức tạp
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isAlarmSet) {
        final now = TimeOfDay.now();
        // Kiểm tra giờ và phút trùng khớp
        if (now.hour == _selectedTime.hour && now.minute == _selectedTime.minute) {
          // Kiểm tra thêm giây = 0 để tránh kích hoạt liên tục trong 1 phút đó
          if (DateTime.now().second == 0) { 
             _triggerAlarm();
          }
        }
      }
    });
  }

  // --- KÍCH HOẠT BÁO THỨC ---
  Future<void> _triggerAlarm() async {
    // Tắt trạng thái đặt để không lặp lại
    setState(() => _isAlarmSet = false);

    try {
      await player.stop(); // Reset trước khi chạy
      await player.play(AssetSource('audio/alarm.mp3'));
    } catch (e) {
      debugPrint("Lỗi phát âm thanh: $e");
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false, // Bắt buộc phải bấm nút
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.pink.shade50,
          title: Row(
            children: const [
              Icon(Icons.access_alarm, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Text('Báo Thức!!!', style: TextStyle(color: Colors.red)),
            ],
          ),
          content: Text(
            'Đã đến giờ: ${_selectedTime.format(context)}',
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _stopAlarm();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Tắt Báo Thức', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  void _stopAlarm() {
    player.stop();
  }

  // --- CHỌN GIỜ THỦ CÔNG ---
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Colors.pink.shade700),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _isAlarmSet = true; // Tự động bật khi chọn giờ mới
        _lastVoiceFeedback = "Đã chỉnh giờ thủ công";
      });
    }
  }

  // --- XỬ LÝ GIỌNG NÓI (TỐI ƯU) ---
  void _handleVoiceCommand(String command) {
    final lowerCaseCommand = command.toLowerCase();
    
    // 1. Lệnh Hủy
    if (lowerCaseCommand.contains('dừng') || 
        lowerCaseCommand.contains('hủy') || 
        lowerCaseCommand.contains('tắt')) {
      setState(() {
        _isAlarmSet = false;
        _stopAlarm();
        _lastVoiceFeedback = "❌ Đã hủy báo thức";
      });
      _showSnackBar("Đã tắt báo thức", Colors.orange);
      return;
    }

    // 2. Lệnh Đặt giờ
    // Regex tìm tất cả các số trong câu lệnh
    final numberRegex = RegExp(r'(\d+)');
    final matches = numberRegex.allMatches(lowerCaseCommand).toList();

    if (matches.isNotEmpty) {
      int? hour;
      int minute = 0; // Mặc định phút là 0 nếu không nói

      // Lấy số đầu tiên làm giờ
      hour = int.tryParse(matches[0].group(0)!);

      // Nếu có số thứ 2, lấy làm phút
      if (matches.length > 1) {
        minute = int.tryParse(matches[1].group(0)!) ?? 0;
      }

      // Validate thời gian
      if (hour != null && hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
        setState(() {
          _selectedTime = TimeOfDay(hour: hour!, minute: minute);
          _isAlarmSet = true;
          _lastVoiceFeedback = "✅ Đã nhận: Đặt ${hour}h ${minute}p";
        });
        _showSnackBar("Đã đặt báo thức lúc ${_selectedTime.format(context)}", Colors.green);
      } else {
        setState(() => _lastVoiceFeedback = "⚠️ Thời gian không hợp lệ");
      }
    } else {
      setState(() => _lastVoiceFeedback = "❓ Không hiểu: \"$command\"");
    }
  }

  void _showSnackBar(String message, Color color) {
    if(!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: const Text('⏰ Đồng Hồ Báo Thức'),
        backgroundColor: Colors.pink.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- PHẦN HIỂN THỊ PHẢN HỒI GIỌNG NÓI ---
              AnimatedOpacity(
                opacity: _lastVoiceFeedback.isNotEmpty ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Text(
                    _lastVoiceFeedback,
                    style: TextStyle(color: Colors.pink.shade800, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),

              // --- ĐỒNG HỒ ---
              GestureDetector(
                onTap: () => _selectTime(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: _isAlarmSet ? Colors.pink.shade400 : Colors.grey.shade300, 
                      width: 2
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _isAlarmSet ? 'BÁO THỨC ĐANG BẬT' : 'CHẠM ĐỂ CHỌN GIỜ',
                        style: TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.bold, 
                          color: _isAlarmSet ? Colors.green : Colors.grey
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _selectedTime.format(context),
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: _isAlarmSet ? Colors.pink.shade700 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 50),

              // --- NÚT BẬT/TẮT ---
              Transform.scale(
                scale: 1.2,
                child: Switch(
                  value: _isAlarmSet,
                  activeColor: Colors.pink.shade700,
                  onChanged: (bool value) {
                    setState(() {
                      _isAlarmSet = value;
                      if (!value) _stopAlarm();
                      _lastVoiceFeedback = value ? "Đã bật thủ công" : "Đã tắt thủ công";
                    });
                  },
                ),
              ),
              Text(
                _isAlarmSet ? "Đang chờ..." : "Đang tắt",
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: VoiceInputButton(onCommand: _handleVoiceCommand),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}