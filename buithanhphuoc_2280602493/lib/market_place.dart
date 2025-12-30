import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:buithanhphuoc_2280602493/model/productPost.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final String baseUrl =
      'https://lasttealtower93.conveyor.cloud/api/ProductApi';

  late Future<List<ProductPost>> _futurePosts;

  List<ProductPost> _allPosts = [];
  List<ProductPost> _filteredPosts = [];

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futurePosts = _fetchPosts();
  }

  // ================= API =================

  Future<List<ProductPost>> _fetchPosts() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      _allPosts = data.map((e) => ProductPost.fromJson(e)).toList();
      _filteredPosts = List.from(_allPosts);
      return _allPosts;
    }
    throw Exception('Lỗi tải dữ liệu');
  }

  Future<ProductPost> _createPost(ProductPost post) async {
    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(post.toJson()),
      );
      print('Create response code: ${res.statusCode}');
      print('Create response body: ${res.body}');
      
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final newPost = ProductPost.fromJson(data);
        setState(() {
          _allPosts.add(newPost);
          _filteredPosts.add(newPost);
        });
        return newPost;
      } else {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      print('Create error: $e');
      rethrow;
    }
  }

  Future<void> _updatePost(ProductPost post) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/${post.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(post.toJson()),
      );
      print('Update response code: ${res.statusCode}');
      print('Update response body: ${res.body}');
      
      if (res.statusCode == 200 || res.statusCode == 204) {
        setState(() {
          final index = _allPosts.indexWhere((p) => p.id == post.id);
          if (index != -1) {
            _allPosts[index] = post;
            _search(_searchCtrl.text);
          }
        });
      } else {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      print('Update error: $e');
      rethrow;
    }
  }

  Future<void> _deletePost(int id) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/$id'),
      );
      print('Delete response code: ${res.statusCode}');
      print('Delete response body: ${res.body}');
      
      if (res.statusCode == 200 || res.statusCode == 204) {
        setState(() {
          _allPosts.removeWhere((p) => p.id == id);
          _filteredPosts.removeWhere((p) => p.id == id);
        });
      } else {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      print('Delete error: $e');
      rethrow;
    }
  }

  // ================= SEARCH =================

  void _search(String value) {
    setState(() {
      _filteredPosts = _allPosts.where((p) {
        final name = (p.name ?? '').toLowerCase();
        final id = p.id?.toString() ?? '';
        return name.contains(value.toLowerCase()) ||
            id.contains(value);
      }).toList();
    });
  }

  // ================= IMAGE =================

  Widget _buildImage(String image) {
    if (image.isEmpty) {
      return _imageError();
    }

    // BASE64
    if (image.startsWith('data:image')) {
      final bytes = base64Decode(image.split(',').last);
      return Image.memory(
        bytes,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    // URL
    return Image.network(
      Uri.encodeFull(image),
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _imageLoading();
      },
      errorBuilder: (context, error, stackTrace) {
        return _imageError();
      },
    );
  }

  Widget _imageLoading() => Container(
        height: 220,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      );

  Widget _imageError() => Container(
        height: 220,
        color: Colors.grey[300],
        child: const Icon(Icons.image_not_supported, size: 48),
      );

  // ================= DIALOGS =================

  void _showAddDialog() {
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
                
                final post = ProductPost(
                  name: nameCtrl.text,
                  price: double.tryParse(priceCtrl.text) ?? 0,
                  description: descCtrl.text,
                  image: imageCtrl.text,
                );
                await _createPost(post);
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

  void _showEditDialog(ProductPost post) {
    final nameCtrl = TextEditingController(text: post.name);
    final priceCtrl = TextEditingController(text: post.price?.toString());
    final descCtrl = TextEditingController(text: post.description);
    final imageCtrl = TextEditingController(text: post.image);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa sản phẩm'),
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
                final updatedPost = ProductPost(
                  id: post.id,
                  name: nameCtrl.text,
                  price: double.tryParse(priceCtrl.text) ?? 0,
                  description: descCtrl.text,
                  image: imageCtrl.text,
                );
                await _updatePost(updatedPost);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cập nhật thành công')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: $e')),
                );
              }
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(ProductPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: Text('Bạn có chắc muốn xóa "${post.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _deletePost(post.id!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Xóa sản phẩm thành công')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f2f5),
      appBar: AppBar(
        title: const Text(
          'Chợ Online',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: FloatingActionButton.extended(
                onPressed: _showAddDialog,
                label: const Text('Đăng bán'),
                icon: const Icon(Icons.add),
                backgroundColor: Colors.blue.shade600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),

          // LIST
          Expanded(
            child: FutureBuilder(
              future: _futurePosts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Lỗi: ${snapshot.error}'),
                  );
                }

                if (_filteredPosts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Không có sản phẩm nào',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: _filteredPosts.length,
                  itemBuilder: (context, index) {
                    final post = _filteredPosts[index];
                    return _MarketCard(
                      post: post,
                      imageBuilder: _buildImage,
                      onEdit: () => _showEditDialog(post),
                      onDelete: () => _showDeleteDialog(post),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================= CARD =================

class _MarketCard extends StatelessWidget {
  final ProductPost post;
  final Widget Function(String) imageBuilder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MarketCard({
    required this.post,
    required this.imageBuilder,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Có thể mở chi tiết sản phẩm
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE SECTION
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: imageBuilder(post.image ?? ''),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: PopupMenuButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: const Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Chỉnh sửa'),
                              ],
                            ),
                            onTap: onEdit,
                          ),
                          PopupMenuItem(
                            child: const Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Xóa'),
                              ],
                            ),
                            onTap: onDelete,
                          ),
                        ],
                        child: const Icon(Icons.more_vert),
                      ),
                    ),
                  ),
                ],
              ),

              // CONTENT SECTION
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      post.name ?? 'Không tên',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Description
                    if ((post.description ?? '').isNotEmpty)
                      Text(
                        post.description ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if ((post.description ?? '').isNotEmpty)
                      const SizedBox(height: 6),

                    // Price - Highlighted
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (post.price != null)
                          Text(
                            '${post.price!.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')} VND',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ID: ${post.id ?? '-'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
