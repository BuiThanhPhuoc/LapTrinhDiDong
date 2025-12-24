import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// Đảm bảo đường dẫn import này chính xác với cấu trúc thư mục của bạn
import 'package:buithanhphuoc_2280602493/model/productPost.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  // Cập nhật baseUrl chính xác của bạn
  final String baseUrl = 'https://smallreddog79.conveyor.cloud/api/ProductApi';
  
  // Biến dùng để trigger việc load lại FutureBuilder
  late Future<List<ProductPost>> _postFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // Hàm làm mới dữ liệu
  void _refreshData() {
    setState(() {
      _postFuture = _fetchPosts();
    });
  }

  // 1. GỌI API LẤY DANH SÁCH (READ)
  Future<List<ProductPost>> _fetchPosts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => ProductPost.fromJson(item)).toList();
      } else {
        throw Exception('Server trả về lỗi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến máy chủ: $e');
    }
  }

  // 2. GỌI API XÓA (DELETE)
  Future<void> _deletePost(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200 || response.statusCode == 204) {
        _showMsg("Đã xóa bài đăng thành công");
        _refreshData();
      } else {
        _showMsg("Lỗi khi xóa: ${response.statusCode}");
      }
    } catch (e) {
      _showMsg("Lỗi kết nối: $e");
    }
  }

  // 3. GỌI API THÊM/SỬA (POST/PUT)
  void _showPostDialog({ProductPost? post}) {
    final nameCtrl = TextEditingController(text: post?.name);
    final priceCtrl = TextEditingController(text: post?.price?.toString());
    final imgCtrl = TextEditingController(text: post?.image);
    final descCtrl = TextEditingController(text: post?.description);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(post == null ? "Tạo bài đăng mới" : "Chỉnh sửa bài đăng"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Tiêu đề/Tên", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceCtrl,
                decoration: const InputDecoration(labelText: "Giá (VND)", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: imgCtrl,
                decoration: const InputDecoration(labelText: "Link ảnh đại diện", border: OutlineInputBorder(), hintText: "https://..."),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Nội dung bài viết", border: OutlineInputBorder()),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () async {
              final data = ProductPost(
                id: post?.id,
                name: nameCtrl.text,
                price: double.tryParse(priceCtrl.text) ?? 0,
                image: imgCtrl.text,
                description: descCtrl.text,
              );

              try {
                if (post == null) {
                  // Thêm mới
                  await http.post(
                    Uri.parse(baseUrl),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode(data.toJson()),
                  );
                } else {
                  // Cập nhật
                  await http.put(
                    Uri.parse('$baseUrl/${post.id}'),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode(data.toJson()),
                  );
                }
                Navigator.pop(ctx);
                _refreshData();
              } catch (e) {
                _showMsg("Lỗi thao tác: $e");
              }
            },
            child: const Text("Đăng", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Bảng tin Sản phẩm'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder<List<ProductPost>>(
        future: _postFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Chưa có bài đăng nào. Hãy tạo mới!"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final post = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                elevation: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.indigo,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        post.name ?? "User",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("ID: ${post.id} • ${post.price?.toStringAsFixed(0)} VND"),
                      trailing: PopupMenuButton(
                        onSelected: (val) {
                          if (val == 'edit') _showPostDialog(post: post);
                          if (val == 'delete') _deletePost(post.id!);
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Sửa")])),
                          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text("Xóa", style: TextStyle(color: Colors.red))])),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: Text(post.description ?? "", style: const TextStyle(fontSize: 15)),
                    ),
                    if (post.image != null && post.image!.isNotEmpty && post.image!.startsWith('http'))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Image.network(
                          post.image!,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(height: 300, color: Colors.grey[300], child: const Center(child: CircularProgressIndicator()));
                          },
                          errorBuilder: (c, e, s) => Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Icon(Icons.broken_image, size: 50, color: Colors.grey), Text("Link ảnh bị hỏng")],
                            ),
                          ),
                        ),
                      ),
                    const Divider(height: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSocialButton(Icons.thumb_up_alt_outlined, "Thích"),
                        _buildSocialButton(Icons.comment_outlined, "Bình luận"),
                        _buildSocialButton(Icons.share_outlined, "Chia sẻ"),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPostDialog(),
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.grey[700], size: 20),
      label: Text(label, style: TextStyle(color: Colors.grey[700])),
    );
  }
}