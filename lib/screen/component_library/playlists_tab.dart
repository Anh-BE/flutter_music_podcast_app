
import 'package:flutter/material.dart';
import '../../models/Supabase_Service.dart';
import '../../models/models_music.dart';
import 'PlaylistDetailScreen.dart';


class PlaylistsTab extends StatelessWidget {
  static final SupabaseService _service = SupabaseService();
  const PlaylistsTab({super.key});

  // Hàm hiển thị ô nhập tên để tạo nhanh Playlist trống
  void _showCreatePlaylistDialog(BuildContext context) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          title: const Text("Tạo Playlist mới", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: textController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Nhập tên playlist của bạn...",
              hintStyle: const TextStyle(color: Colors.white30),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[600]!)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.purple)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy", style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: () async {
                final name = textController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.pop(context);
                  final error = await _service.createPlaylist(name);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error ?? "Đã tạo playlist '$name' trống thành công!"),
                        backgroundColor: error != null ? Colors.redAccent : Colors.green,
                      ),
                    );
                  }
                }
              },
              child: const Text("Tạo", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlaylistModel>>(
      stream: _service.getMyPlaylistsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.purple),
          );
        }

        // Lấy danh sách playlist từ snapshot (nếu chưa có dữ liệu thì gán mảng rỗng)
        final playlists = snapshot.data ?? [];

        // Trả về GridView chuẩn cấu trúc nằm bên trong khối builder của StreamBuilder
        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 1 + playlists.length,
          itemBuilder: (context, index) {
            // Ô index == 0: Ô chức năng tạo Playlist mới
            if (index == 0) {
              return GestureDetector(
                onTap: () {
                  _showCreatePlaylistDialog(context);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF242424),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(Icons.add_rounded, color: Colors.white54, size: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tạo Playlist mới',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }

            // Các ô index > 0: Hiển thị các Playlist lấy từ Database Supabase về
            final playlistItem = playlists[index - 1];

            return GestureDetector(
              onTap: () {
                // 🔥 CHUYỂN HƯỚNG SANG MÀN HÌNH CHI TIẾT PLAYLIST ĐỂ XEM VÀ XÓA BÀI HÁT
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaylistDetailScreen(playlist: playlistItem),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF333333),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.music_note_rounded, color: Colors.purpleAccent, size: 45),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    playlistItem.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Playlist • Bạn tạo',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}