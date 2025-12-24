import 'package:flutter/material.dart';

// --- IMPORT CÁC MÀN HÌNH CHỨC NĂNG ---
import 'package:buithanhphuoc_2280602493/alarm_screen.dart';
import 'package:buithanhphuoc_2280602493/stopwatch_screen.dart';
import 'package:buithanhphuoc_2280602493/temperature_converter_screen.dart';
import 'package:buithanhphuoc_2280602493/unit_converter_screen.dart';
import 'package:buithanhphuoc_2280602493/youtube_viewer_screen.dart';
import 'package:buithanhphuoc_2280602493/voice_commander_screen.dart';
import 'package:buithanhphuoc_2280602493/information_screen.dart';
import 'package:buithanhphuoc_2280602493/translate_screen.dart'; 
// Đảm bảo file market_place.dart của bạn đã đổi sang StatefulWidget như mình gửi nhé
import 'package:buithanhphuoc_2280602493/market_place.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // --- HÀM ĐIỀU HƯỚNG TAB ---
  Widget _getBodyWidget() {
    switch (_selectedIndex) {
      case 0: return _buildHomeDashboard();
      case 1: return const TemperatureConverterScreen();
      case 2: return const UnitConverterScreen();
      case 3: return const StopwatchScreen();
      case 4: return const AlarmScreen();
      case 5: return const YoutubeViewerScreen();
      case 6: return const TranslateScreen();
      case 7: return const InformationScreen();
      default: return _buildHomeDashboard();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          '🔥 Ứng Dụng Đa Năng',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _getBodyWidget(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.indigo.shade700,
        unselectedItemColor: Colors.grey.shade400,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 26,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.thermostat_rounded), label: 'Temp'),
          BottomNavigationBarItem(icon: Icon(Icons.straighten_rounded), label: 'Unit'),
          BottomNavigationBarItem(icon: Icon(Icons.timer_rounded), label: 'Timer'),
          BottomNavigationBarItem(icon: Icon(Icons.access_alarm_rounded), label: 'Alarm'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library_rounded), label: 'Video'),
          BottomNavigationBarItem(icon: Icon(Icons.translate_rounded), label: 'Trans'),
          BottomNavigationBarItem(icon: Icon(Icons.groups_rounded), label: 'Info'),
        ],
      ),
    );
  }

  // --- GIAO DIỆN TRANG CHỦ (DASHBOARD) ---
  Widget _buildHomeDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWideCard(
            context,
            title: 'Giọng Nói AI',
            subtitle: 'Điều khiển mở tính năng bằng giọng nói',
            icon: Icons.record_voice_over,
            color: Colors.blue.shade600,
            targetScreen: const VoiceCommanderScreen(),
          ),
          const SizedBox(height: 25),
          const Text(
            'Danh sách chức năng:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 15),

          // Lưới menu - Đã sắp xếp lại 7 ô chức năng chính xác
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, 
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.3,
            children: [
              _buildGridCard(
                context,
                title: 'Nhiệt Độ',
                subtitle: 'C, F, K',
                icon: Icons.thermostat_outlined,
                color: Colors.deepOrange.shade400,
                targetScreen: const TemperatureConverterScreen(),
              ),
              _buildGridCard(
                context,
                title: 'Đơn Vị Đo',
                subtitle: 'Độ dài, Khối lượng',
                icon: Icons.straighten,
                color: Colors.teal.shade400,
                targetScreen: const UnitConverterScreen(),
              ),
              _buildGridCard(
                context,
                title: 'Bấm Giờ',
                subtitle: 'Tính năng Lap',
                icon: Icons.timer,
                color: Colors.blueGrey.shade600,
                targetScreen: const StopwatchScreen(),
              ),
              _buildGridCard(
                context,
                title: 'Báo Thức',
                subtitle: 'Real-time Alarm',
                icon: Icons.access_alarm,
                color: Colors.pink.shade600,
                targetScreen: const AlarmScreen(),
              ),
              _buildGridCard(
                context,
                title: 'YouTube',
                subtitle: 'Xem video online',
                icon: Icons.video_library_rounded,
                color: Colors.red.shade600,
                targetScreen: const YoutubeViewerScreen(),
              ),
              
              // Ô CỬA HÀNG (Market) - Đã xóa mục trùng lặp
              _buildGridCard(
                context,
                title: 'Cửa Hàng',
                subtitle: 'Quản lý sản phẩm',
                icon: Icons.shopping_bag_outlined,
                color: Colors.orange.shade700,
                targetScreen: const MarketScreen(), 
              ),

              _buildGridCard(
                context,
                title: 'Dịch AI (VIP)',
                subtitle: 'Cam, Voice, Text',
                icon: Icons.translate,
                color: Colors.purple.shade500,
                targetScreen: const TranslateScreen(),
              ),
            ],
          ),

          const SizedBox(height: 30),
          const Center(
            child: Text('Góc Thư Giãn:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildImageItem('assets/images/Yasuo.jpg', 'Yasuo'),
              _buildImageItem('assets/images/Trinh.jpg', 'Trinh'),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- UI COMPONENTS GIỮ NGUYÊN ---
  Widget _buildWideCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required Widget targetScreen}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen)),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, size: 30, color: color)),
              const SizedBox(width: 15),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo.shade900)), const SizedBox(height: 5), Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey))])),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required Widget targetScreen}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen)),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo.shade800)),
              const SizedBox(height: 4),
              Flexible(child: Text(subtitle, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey.shade600))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageItem(String assetPath, String name) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(assetPath, height: 120, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(height: 120, color: Colors.grey.shade300, child: Center(child: Text("$name lỗi", style: const TextStyle(fontSize: 10))))),
        ),
      ),
    );
  }
}