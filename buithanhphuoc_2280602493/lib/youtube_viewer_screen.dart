import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Để dùng Clipboard
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeViewerScreen extends StatefulWidget {
  const YoutubeViewerScreen({super.key});

  @override
  State<YoutubeViewerScreen> createState() => _YoutubeViewerScreenState();
}

class _YoutubeViewerScreenState extends State<YoutubeViewerScreen> {
  final TextEditingController _urlController = TextEditingController();
  late YoutubePlayerController _playerController;
  
  // Video mặc định (Nhạc Lofi Chill)
  final String _defaultVideoId = 'jfKfPfyJRdk'; 

  @override
  void initState() {
    super.initState();
    _playerController = YoutubePlayerController(
      initialVideoId: _defaultVideoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
      ),
    );
  }

  // Hàm load video
  void _loadVideo(String? url) {
    if (url == null || url.isEmpty) return;
    
    // Tự động ẩn bàn phím
    FocusScope.of(context).unfocus();

    final String? videoId = YoutubePlayer.convertUrlToId(url);

    if (videoId != null) {
      _playerController.load(videoId);
      _urlController.clear(); // Xóa ô nhập sau khi load thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang phát video...')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi: Link YouTube không hợp lệ!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Hàm dán từ bộ nhớ tạm
  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _urlController.text = data!.text!;
      _loadVideo(data.text); // Tự động load luôn sau khi dán
    }
  }

  @override
  void dispose() {
    _playerController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // YoutubePlayerBuilder giúp xử lý FullScreen tốt hơn
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _playerController,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            title: const Text('▶️ YouTube Player'),
            centerTitle: true,
            backgroundColor: Colors.black, // Màu đỏ đặc trưng Youtube hoặc Đen
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Column(
            children: [
              // 1. KHU VỰC VIDEO PLAYER
              player,

              // 2. KHU VỰC ĐIỀU KHIỂN
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Card Nhập Link ---
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              const Text(
                                "Nhập Link Video",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _urlController,
                                      decoration: InputDecoration(
                                        hintText: 'https://youtu.be/...',
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.paste, color: Colors.red),
                                          tooltip: 'Dán & Phát',
                                          onPressed: _pasteFromClipboard,
                                        ),
                                      ),
                                      onSubmitted: _loadVideo,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () => _loadVideo(_urlController.text),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.all(15),
                                      shape: const CircleBorder(),
                                    ),
                                    child: const Icon(Icons.play_arrow),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                      const Text(
                        "Video Mẫu (Test nhanh):",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 10),

                      // --- Danh sách Video mẫu ---
                      _buildPresetVideoTile("Nhạc Lofi Chill", "jfKfPfyJRdk", Colors.purple),
                      _buildPresetVideoTile("Tin tức Flutter", "CD1Y2DmL5JM", Colors.blue),
                      _buildPresetVideoTile("Mèo máy Doremon", "3tmd-ClpJxA", Colors.teal),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget hiển thị video mẫu
  Widget _buildPresetVideoTile(String title, String videoId, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.play_circle_fill, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("ID: $videoId"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () {
          _playerController.load(videoId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đang phát: $title')),
          );
        },
      ),
    );
  }
}