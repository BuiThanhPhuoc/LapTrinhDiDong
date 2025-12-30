import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// --- IMPORT CÁC MÀN HÌNH CHỨC NĂNG ---
import 'package:buithanhphuoc_2280602493/alarm_screen.dart';
import 'package:buithanhphuoc_2280602493/stopwatch_screen.dart';
import 'package:buithanhphuoc_2280602493/temperature_converter_screen.dart';
import 'package:buithanhphuoc_2280602493/unit_converter_screen.dart';
import 'package:buithanhphuoc_2280602493/youtube_viewer_screen.dart';
import 'package:buithanhphuoc_2280602493/voice_commander_screen.dart';
import 'package:buithanhphuoc_2280602493/information_screen.dart';
import 'package:buithanhphuoc_2280602493/translate_screen.dart'; 
import 'package:buithanhphuoc_2280602493/market_place.dart';
import 'package:buithanhphuoc_2280602493/login_screen.dart';
import 'package:buithanhphuoc_2280602493/model/productPost.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final String baseUrl = 'https://lasttealtower93.conveyor.cloud/api/ProductApi';
  late Future<List<ProductPost>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = _fetchProducts();
  }

  Future<List<ProductPost>> _fetchProducts() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => ProductPost.fromJson(e)).toList();
    }
    throw Exception('Lỗi tải dữ liệu');
  }

  Future<void> _createProduct(ProductPost product) async {
    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );
      print('Create response code: ${res.statusCode}');
      print('Create response body: ${res.body}');
      
      if (res.statusCode == 200 || res.statusCode == 201) {
        setState(() {
          _futureProducts = _fetchProducts();
        });
      } else {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      print('Create error: $e');
      rethrow;
    }
  }

  void _showAddProductDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final imageCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm sản phẩm mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Tên sản phẩm',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Giá (VND)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imageCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'URL Hình ảnh',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                if (nameCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập tên sản phẩm')),
                  );
                  return;
                }

                final product = ProductPost(
                  name: nameCtrl.text,
                  price: double.tryParse(priceCtrl.text) ?? 0,
                  description: descCtrl.text,
                  image: imageCtrl.text,
                );
                await _createProduct(product);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thêm sản phẩm thành công')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: $e')),
                );
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  // HÀM ĐĂNG XUẤT
  Future<void> _handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  // --- ĐIỀU HƯỚNG ---
  Widget _getBodyWidget() {
    switch (_selectedIndex) {
      case 0: 
        return _buildHomeDashboard();
      case 1: 
        return const MarketScreen();
      case 3: 
        return _buildImageGallery();
      case 4: 
        return const InformationScreen();
      default: 
        return _buildHomeDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4E6EB),
      appBar: AppBar(
        title: const Text(
          'facebook',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 32,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: const Color(0xFF0A66C2),
        elevation: 2,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, size: 28, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: _handleLogout,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _getBodyWidget(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0A66C2),
        unselectedItemColor: Colors.grey.shade400,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 2) {
            // Nút + để thêm sản phẩm
            _showAddProductDialog();
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, size: 26),
            label: 'Trang chủ',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.storefront_rounded, size: 26),
            label: 'Chợ',
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0A66C2),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            label: 'Thêm',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.image_rounded, size: 26),
            label: 'Ảnh',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.info_rounded, size: 26),
            label: 'Info',
          ),
        ],
      ),
    );
  }

  // --- DRAWER MENU ---
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF0A66C2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_rounded,
                    size: 44,
                    color: const Color(0xFF0A66C2),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Phước Multi-App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem('Chợ Online', Icons.storefront_rounded, 1),
          _buildDrawerItem('Giọng Nói AI', Icons.mic_rounded, null, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VoiceCommanderScreen(),
              ),
            );
          }),
          _buildDrawerItem('Nhiệt Độ', Icons.thermostat_rounded, null, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TemperatureConverterScreen(),
              ),
            );
          }),
          _buildDrawerItem('Đơn Vị', Icons.straighten_rounded, null, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UnitConverterScreen(),
              ),
            );
          }),
          _buildDrawerItem('Bấm Giờ', Icons.timer_outlined, null, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StopwatchScreen(),
              ),
            );
          }),
          _buildDrawerItem('Báo Thức', Icons.alarm_on_rounded, null, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AlarmScreen(),
              ),
            );
          }),
          _buildDrawerItem('YouTube', Icons.play_circle_fill_rounded, null, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const YoutubeViewerScreen(),
              ),
            );
          }),
          _buildDrawerItem('Dịch Thuật', Icons.translate_rounded, null, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TranslateScreen(),
              ),
            );
          }),
          const Divider(),
          _buildDrawerItem('Thông Tin', Icons.info_rounded, null, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const InformationScreen(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    String title,
    IconData icon,
    int? navIndex, [
    VoidCallback? onTap,
  ]) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0A66C2)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap ??
          () {
            Navigator.pop(context);
            if (navIndex != null) {
              setState(() => _selectedIndex = navIndex);
            }
          },
    );
  }

  // --- HOME DASHBOARD ---
  Widget _buildHomeDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          // Status Update Box
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF0A66C2).withOpacity(0.2),
                    child: const Icon(Icons.person,
                        color: Color(0xFF0A66C2)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Bạn đang nghĩ gì?',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.image_rounded,
                        color: Color(0xFF0A66C2)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Marketplace Feed
          FutureBuilder<List<ProductPost>>(
            future: _futureProducts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Lỗi: ${snapshot.error}'),
                );
              }

              final products = snapshot.data ?? [];
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _buildProductPost(product);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // --- PRODUCT POST CARD (Like Facebook Post) ---
  Widget _buildProductPost(ProductPost product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF0A66C2).withOpacity(0.2),
                  child: const Icon(Icons.store,
                      color: Color(0xFF0A66C2)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name ?? 'Sản phẩm',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'ID: ${product.id ?? '-'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz, color: Colors.grey),
              ],
            ),
          ),

          // Image
          if ((product.image ?? '').isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildProductImage(product.image ?? ''),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((product.description ?? '').isNotEmpty)
                  Text(
                    product.description ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (product.price != null)
                      Text(
                        '${product.price!.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')} VND',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A66C2),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A66C2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Chi tiết',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF0A66C2),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Reaction Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.thumb_up_outlined, size: 20),
                  label: const Text('Thích'),
                  onPressed: () {},
                ),
                TextButton.icon(
                  icon: const Icon(Icons.comment_outlined, size: 20),
                  label: const Text('Bình luận'),
                  onPressed: () {},
                ),
                TextButton.icon(
                  icon: const Icon(Icons.share_outlined, size: 20),
                  label: const Text('Chia sẻ'),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // --- BUILD PRODUCT IMAGE ---
  Widget _buildProductImage(String image) {
    if (image.isEmpty) {
      return Container(
        height: 250,
        color: Colors.grey[300],
        child: const Icon(Icons.image_not_supported, size: 48),
      );
    }

    if (image.startsWith('data:image')) {
      try {
        final bytes = base64Decode(image.split(',').last);
        return Image.memory(
          bytes,
          height: 250,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } catch (e) {
        return Container(
          height: 250,
          color: Colors.grey[300],
          child: const Icon(Icons.error_outline, size: 48),
        );
      }
    }

    return Image.network(
      Uri.encodeFull(image),
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          height: 250,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 250,
          color: Colors.grey[300],
          child: const Icon(Icons.image_not_supported, size: 48),
        );
      },
    );
  }

  // --- IMAGE GALLERY ---
  Widget _buildImageGallery() {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(8),
      children: [
        _buildGalleryImage('assets/images/Yasuo.jpg', 'Yasuo'),
        _buildGalleryImage('assets/images/Trinh.jpg', 'Trinh'),
      ],
    );
  }

  Widget _buildGalleryImage(String path, String label) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(
          color: Colors.grey.shade300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.image_not_supported, size: 40),
                const SizedBox(height: 8),
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

  // Old code to be removed - no longer needed