import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../colors/app_colors.dart';
import '../../models/models_music.dart';
import '../play_song.dart';

class SongsTab extends StatelessWidget {
  const SongsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      return const Center(
        child: Text(
          'Vui lòng đăng nhập để xem bài hát đã thích',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }

    // Lắng nghe dữ liệu thời gian thực từ bảng 'liked_songs' của User hiện tại
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('liked_songs')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Có lỗi xảy ra: ${snapshot.error}',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        final likedRecords = snapshot.data ?? [];

        if (likedRecords.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, color: Colors.white24, size: 48),
                SizedBox(height: 12),
                Text(
                  'Chưa có bài hát yêu thích nào',
                  style: TextStyle(color: Colors.white38, fontSize: 14),
                ),
              ],
            ),
          );
        }

        // Lấy danh sách các ID bài hát đã thích
        final List<int> songIds = likedRecords
            .map((item) => item['song_id'] as int)
            .toList();

        // Tiếp tục dùng một StreamBuilder/FutureBuilder hoặc truy vấn trực tiếp bảng songs để lấy thông tin chi tiết
        // Để tối ưu và đồng bộ giao diện mượt mà nhất, ta query danh sách chi tiết các bài hát:
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: supabase
              .from('songs')
              .stream(primaryKey: ['id'])
              .order('id'),
          builder: (context, songSnapshot) {
            if (!songSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            // Lọc ra những bài hát nằm trong danh sách Id đã thích của User
            final allSongs = songSnapshot.data ?? [];
            final List<BaiHatModel> favoriteSongs = allSongs
                .where((songMap) => songIds.contains(songMap['id'] as int))
                .map((json) => BaiHatModel.fromMap(json))
                .toList();

            if (favoriteSongs.isEmpty) {
              return const Center(
                child: Text('Đang tải danh sách bài hát...', style: TextStyle(color: Colors.white54)),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              itemCount: favoriteSongs.length,
              itemBuilder: (context, index) {
                final item = favoriteSongs[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: InkWell(
                    onTap: () {
                      // 🎵 CHỨC NĂNG PHÁT NHẠC: Điều hướng sang màn hình NowPlayingScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NowPlayingScreen(
                            Baihat: item,          // Bài hát hiện tại được chọn
                            ListBaihat: favoriteSongs, // Danh sách phát (Playlist các bài đã thích)
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      children: [
                        // Ảnh bìa bài hát
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            item.imageURl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              width: 56,
                              height: 56,
                              color: Colors.grey[800],
                              child: const Icon(Icons.music_note, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Thông tin tiêu đề & Ca sĩ
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.artist,
                                style: const TextStyle(color: Colors.white54, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Icon Trái tim biểu thị trạng thái đã thích (Luôn là màu button/pink vì nằm trong Tab Yêu thích)
                        const Icon(Icons.favorite, color: AppColors.button, size: 22),
                        const SizedBox(width: 16),
                        const Icon(Icons.more_vert, color: Colors.white54),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}