import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// 1. Model dữ liệu cho thành viên
class MemberInfo {
  final String name;
  final String id;
  final String phoneNumber;
  final String imagePath;
  final String role;
  final String youtubeLink;

  MemberInfo({
    required this.name,
    required this.id,
    required this.phoneNumber,
    required this.imagePath,
    required this.role,
    this.youtubeLink = 'https://www.youtube.com/watch?v=Q4cDgcvPBG4', // Link mặc định
  });
}

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  // 2. Danh sách 4 thành viên
  final List<MemberInfo> members = [
    MemberInfo(
      name: "Bùi Thanh Phước",
      id: "2280602493",
      phoneNumber: "0358944287",
      imagePath: "assets/images/Yasuo.jpg", // Đảm bảo có ảnh này trong assets
      role: "Trưởng Nhóm (Leader)",
    ),
    MemberInfo(
      name: "Lê Minh Nhật",
      id: "2280602198",
      phoneNumber: "0909123456",
      imagePath: "assets/images/Trinh.jpg", // Đảm bảo có ảnh này trong assets
      role: "Lập Trình Viên (Dev)",
    ),
    MemberInfo(
      name: "Nguyễn Chí Thanh",
      id: "2280602948",
      phoneNumber: "0912345678",
      imagePath: "assets/images/Yasuo.jpg", // Dùng tạm ảnh lặp lại nếu thiếu
      role: "Thiết Kế (UI/UX)",
    ),
    MemberInfo(
      name: "Nguyễn Duy Tài",
      id: "2280602796",
      phoneNumber: "0987654321",
      imagePath: "assets/images/Trinh.jpg", // Dùng tạm ảnh lặp lại nếu thiếu
      role: "Kiểm Thử (Tester)",
    ),
  ];

  // Hàm gọi điện (Dynamic theo số điện thoại)
  Future<void> _makePhoneCall(BuildContext context, String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        // Fallback cho một số máy ảo hoặc thiết bị kén
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể gọi: $e')),
        );
      }
    }
  }

  // Hàm mở YouTube
  Future<void> _openYoutube(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở liên kết.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👥 Thông tin Nhóm'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Vuốt để xem thành viên khác",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
          // 3. PageView để lướt
          Expanded(
            child: PageView.builder(
              itemCount: members.length,
              physics: const BouncingScrollPhysics(), // Hiệu ứng lướt mượt
              itemBuilder: (context, index) {
                return _buildMemberCard(members[index], index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị thẻ thành viên
  Widget _buildMemberCard(MemberInfo member, int index) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Số thứ tự
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "$index / ${members.length}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
            ),
            
            // Avatar
            Container(
              padding: const EdgeInsets.all(4), // Viền trắng
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.indigo.shade100, width: 2),
              ),
              child: CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage(member.imagePath),
                backgroundColor: Colors.grey.shade200,
                onBackgroundImageError: (_, __) {
                  // Xử lý khi ảnh lỗi (nếu chưa có ảnh thật)
                },
                child: member.imagePath.isEmpty 
                    ? const Icon(Icons.person, size: 60, color: Colors.grey) 
                    : null,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Tên và Vai trò
            Text(
              member.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: Colors.indigo
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                member.role,
                style: TextStyle(fontSize: 16, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
              ),
            ),
            
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            // Thông tin chi tiết
            _buildInfoRow(Icons.badge, "MSSV:", member.id),
            const SizedBox(height: 15),
            _buildInfoRow(Icons.phone, "SĐT:", member.phoneNumber),

            const SizedBox(height: 30),

            // Các nút hành động
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.phone_in_talk,
                    label: 'Gọi ngay',
                    color: Colors.green.shade600,
                    onTap: () => _makePhoneCall(context, member.phoneNumber),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.play_circle_fill,
                    label: 'YouTube',
                    color: Colors.red.shade600,
                    onTap: () => _openYoutube(context, member.youtubeLink),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget con: Dòng thông tin (Icon + Label + Value)
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo.shade400, size: 24),
        const SizedBox(width: 15),
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Widget con: Nút bấm
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}