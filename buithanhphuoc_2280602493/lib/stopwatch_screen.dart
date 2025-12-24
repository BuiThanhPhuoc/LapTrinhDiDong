import 'dart:async';
import 'package:flutter/material.dart';
import 'voice_input_button.dart'; // Đảm bảo đã có file này

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  final List<Duration> _laps = [];
  Timer? _timer;
  
  // Controller để cuộn danh sách Lap xuống dưới cùng
  final ScrollController _scrollController = ScrollController();

  String _formattedTime = '00:00.00';

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  // Hàm update thời gian (tách riêng để tái sử dụng)
  void _updateTime() {
    if (mounted) {
      setState(() {
        _formattedTime = _formatDuration(_stopwatch.elapsed);
      });
    }
  }

  // Format MM:SS.ms
  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = (d.inMilliseconds.remainder(1000) ~/ 10)
        .toString()
        .padLeft(2, '0');
    return "$m:$s.$ms";
  }

  // --- LOGIC CHỨC NĂNG ---

  void _start() {
    if (_stopwatch.isRunning) return;
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) => _updateTime());
    _updateUI();
  }

  void _stop() {
    if (!_stopwatch.isRunning) return;
    _stopwatch.stop();
    _timer?.cancel();
    _updateUI();
  }

  // Hàm Reset toàn bộ (chỉ hiện khi đã dừng)
  void _reset() {
    _stop(); // Đảm bảo đã dừng
    _stopwatch.reset();
    _laps.clear();
    _updateTime(); // Reset về 00:00.00
  }

  void _addLap() {
    if (_stopwatch.isRunning) {
      setState(() {
        _laps.insert(0, _stopwatch.elapsed); // Thêm vào đầu danh sách để cái mới nhất lên trên
      });
    }
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  // --- XỬ LÝ GIỌNG NÓI ---
  void _handleVoiceCommand(String cmd) {
    final c = cmd.toLowerCase();
    String feedback = "";

    if (c.contains('bắt đầu') || c.contains('chạy') || c.contains('tiếp tục')) {
      _start();
      feedback = "Đã bắt đầu";
    } else if (c.contains('dừng') || c.contains('ngừng')) {
      _stop();
      feedback = "Đã dừng";
    } else if (c.contains('lap') || c.contains('ghi') || c.contains('vòng')) {
      _addLap();
      feedback = "Đã ghi vòng";
    } else if (c.contains('reset') || c.contains('đặt lại') || c.contains('xóa')) {
      _reset();
      feedback = "Đã đặt lại";
    } else {
      feedback = "Không hiểu lệnh: $cmd";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(feedback),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRunning = _stopwatch.isRunning;
    final bool hasData = _stopwatch.elapsedMilliseconds > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('⏱️ Đồng Hồ Bấm Giờ'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. KHU VỰC HIỂN THỊ GIỜ (Chiếm 40% màn hình)
          Expanded(
            flex: 4,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                _formattedTime,
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w300,
                  color: Colors.black87,
                  fontFeatures: [FontFeature.tabularFigures()], // Giúp số không bị nhảy
                ),
              ),
            ),
          ),

          // 2. KHU VỰC NÚT BẤM (Chiếm 20%)
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --- NÚT TRÁI (Biến hình: LAP hoặc RESET) ---
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: FloatingActionButton(
                      heroTag: 'leftBtn',
                      elevation: 0,
                      // Nếu đang chạy -> Hiện LAP. Nếu đang dừng và có dữ liệu -> Hiện RESET.
                      onPressed: isRunning 
                          ? _addLap 
                          : (hasData ? _reset : null), // Disable nếu chưa chạy tí nào
                      backgroundColor: isRunning 
                          ? Colors.grey.shade300 
                          : (hasData ? Colors.grey.shade300 : Colors.grey.shade200),
                      shape: const CircleBorder(),
                      child: Text(
                        isRunning ? 'Vòng' : 'Đặt lại',
                        style: TextStyle(
                          color: isRunning 
                              ? Colors.black87 
                              : (hasData ? Colors.black87 : Colors.grey), 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),

                  // --- NÚT PHẢI (Biến hình: START hoặc STOP) ---
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: FloatingActionButton(
                      heroTag: 'rightBtn',
                      elevation: 4,
                      onPressed: isRunning ? _stop : _start,
                      backgroundColor: isRunning ? Colors.red.shade100 : Colors.green.shade100,
                      shape: CircleBorder(
                        side: BorderSide(
                          color: isRunning ? Colors.red : Colors.green, 
                          width: 2
                        )
                      ),
                      child: Text(
                        isRunning ? 'Dừng' : 'Bắt đầu',
                        style: TextStyle(
                          color: isRunning ? Colors.red.shade900 : Colors.green.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // 3. KHU VỰC DANH SÁCH LAP (Chiếm 40%)
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
              child: _laps.isEmpty
                  ? Center(
                      child: Text(
                        "Chưa có vòng nào",
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: _laps.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        // Tính toán thời gian chênh lệch giữa các vòng
                        final lapTotal = _laps[index];
                        // Vì mình insert(0) nên logic tính diff hơi khác:
                        // Lap hiện tại trừ đi Lap liền sau nó (nếu có)
                        final Duration lapDiff = (index < _laps.length - 1) 
                            ? lapTotal - _laps[index + 1] 
                            : lapTotal;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Text(
                            'Vòng ${_laps.length - index}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          title: Center(
                            child: Text(
                               "+ ${_formatDuration(lapDiff)}", // Thời gian của riêng vòng đó
                               style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ),
                          trailing: Text(
                            _formatDuration(lapTotal), // Tổng thời gian tại thời điểm bấm Lap
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      
      // Nút điều khiển giọng nói
      floatingActionButton: VoiceInputButton(onCommand: _handleVoiceCommand),
    );
  }
}