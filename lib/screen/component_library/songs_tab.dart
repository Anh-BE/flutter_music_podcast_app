// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../colors/app_colors.dart';
// import '../../models/models_music.dart';
// import '../play_song.dart';
// import '../../models/Supabase_Service.dart';
//
// class SongsTab extends StatelessWidget {
//   const SongsTab({super.key});
//
//   // Khởi tạo service xử lý dữ liệu
//   static final SupabaseService _supabaseService = SupabaseService();
//
//   // Hàm hiển thị tùy chọn Bottom Sheet khi nhấn vào 3 chấm
//   void _showMoreOptions(BuildContext context, BaiHatModel song) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: const Color(0xFF181818),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//
//               Container(
//                 margin: const EdgeInsets.symmetric(vertical: 12),
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.white24,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//
//               // Thông tin bài hát thu nhỏ trong Bottom Sheet
//               ListTile(
//                 leading: ClipRRect(
//                   borderRadius: BorderRadius.circular(4),
//                   child: Image.network(
//                     song.imageURl,
//                     width: 40,
//                     height: 40,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 title: Text(
//                   song.title,
//                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 subtitle: Text(
//                   song.artist,
//                   style: const TextStyle(color: Colors.white54, fontSize: 12),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               const Divider(color: Colors.white10),
//
//               // NÚT CHỨC NĂNG CHÍNH: Bỏ thích bài hát
//               ListTile(
//                 leading: const Icon(Icons.favorite_rounded, color: Colors.grey),
//                 title: const Text(
//                   'Xóa khỏi danh sách yêu thích',
//                   style: TextStyle(color: Colors.white, fontSize: 15),
//                 ),
//                 onTap: () async {
//                   Navigator.pop(context); // Đóng Bottom Sheet trước
//
//                   try {
//                     // Gọi hàm xử lý xóa khỏi bảng liked_songs của bạn
//                     await _supabaseService.toggleLikeSong(song.id);
//
//                     // Hiện thông báo nhỏ thông báo thành công
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Đã xóa "${song.title}" khỏi danh sách yêu thích'),
//                         backgroundColor: Colors.purple,
//                         duration: const Duration(seconds: 2),
//                       ),
//                     );
//                   } catch (e) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.redAccent),
//                     );
//                   }
//                 },
//               ),
//
//
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final supabase = Supabase.instance.client;
//     final userId = supabase.auth.currentUser?.id;
//
//     if (userId == null) {
//       return const Center(
//         child: Text(
//           'Vui lòng đăng nhập để xem bài hát đã thích',
//           style: TextStyle(color: Colors.white54, fontSize: 14),
//         ),
//       );
//     }
//
//     // Lắng nghe dữ liệu thời gian thực từ bảng 'liked_songs' của User hiện tại
//     return StreamBuilder<List<Map<String, dynamic>>>(
//       stream: supabase
//           .from('liked_songs')
//           .stream(primaryKey: ['id'])
//           .eq('user_id', userId)
//           .order('created_at', ascending: false),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(color: AppColors.primary),
//           );
//         }
//
//         if (snapshot.hasError) {
//           return Center(
//             child: Text(
//               'Có lỗi xảy ra: ${snapshot.error}',
//               style: const TextStyle(color: Colors.redAccent),
//             ),
//           );
//         }
//
//         final likedRecords = snapshot.data ?? [];
//
//         if (likedRecords.isEmpty) {
//           return const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.favorite_border, color: Colors.white24, size: 48),
//                 SizedBox(height: 12),
//                 Text(
//                   'Chưa có bài hát yêu thích nào',
//                   style: TextStyle(color: Colors.white38, fontSize: 14),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         // Lấy danh sách các ID bài hát đã thích
//         final List<int> songIds = likedRecords
//             .map((item) => item['song_id'] as int)
//             .toList();
//
//         // Tiếp tục dùng một StreamBuilder/FutureBuilder hoặc truy vấn trực tiếp bảng songs để lấy thông tin chi tiết
//         // Để tối ưu và đồng bộ giao diện mượt mà nhất, ta query danh sách chi tiết các bài hát:
//         return StreamBuilder<List<Map<String, dynamic>>>(
//           stream: supabase
//               .from('songs')
//               .stream(primaryKey: ['id'])
//               .order('id'),
//           builder: (context, songSnapshot) {
//             if (!songSnapshot.hasData) {
//               return const Center(child: CircularProgressIndicator(color: AppColors.primary));
//             }
//
//             // Lọc ra những bài hát nằm trong danh sách Id đã thích của User
//             final allSongs = songSnapshot.data ?? [];
//             final List<BaiHatModel> favoriteSongs = allSongs
//                 .where((songMap) => songIds.contains(songMap['id'] as int))
//                 .map((json) => BaiHatModel.fromMap(json))
//                 .toList();
//
//             if (favoriteSongs.isEmpty) {
//               return const Center(
//                 child: Text('Đang tải danh sách bài hát...', style: TextStyle(color: Colors.white54)),
//               );
//             }
//
//             return ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//               itemCount: favoriteSongs.length,
//               itemBuilder: (context, index) {
//                 final item = favoriteSongs[index];
//
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: InkWell(
//                     onTap: () {
//                       // 🎵 CHỨC NĂNG PHÁT NHẠC: Điều hướng sang màn hình NowPlayingScreen
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => NowPlayingScreen(
//                             Baihat: item,          // Bài hát hiện tại được chọn
//                             ListBaihat: favoriteSongs, // Danh sách phát (Playlist các bài đã thích)
//                           ),
//                         ),
//                       );
//                     },
//                     borderRadius: BorderRadius.circular(8),
//                     child: Row(
//                       children: [
//                         // Ảnh bìa bài hát
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(4),
//                           child: Image.network(
//                             item.imageURl,
//                             width: 56,
//                             height: 56,
//                             fit: BoxFit.cover,
//                             errorBuilder: (c, e, s) => Container(
//                               width: 56,
//                               height: 56,
//                               color: Colors.grey[800],
//                               child: const Icon(Icons.music_note, color: Colors.white),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//
//                         // Thông tin tiêu đề & Ca sĩ
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 item.title,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 15,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 item.artist,
//                                 style: const TextStyle(color: Colors.white54, fontSize: 13),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         // // Icon Trái tim biểu thị trạng thái đã thích (Luôn là màu button/pink vì nằm trong Tab Yêu thích)
//                         // const Icon(Icons.favorite, color: Colors.redAccent, size: 22),
//                         const SizedBox(width: 16),
//                         // const Icon(Icons.more_vert, color: Colors.white54),
//                         IconButton(
//                           icon: const Icon(Icons.more_vert, color:  AppColors.primary),
//                           onPressed: () {
//                             _showMoreOptions(context, item);
//                           },
//
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../colors/app_colors.dart';
import '../../models/models_music.dart';
import '../play_song.dart';
import '../../models/Supabase_Service.dart';

class SongsTab extends StatelessWidget {
  const SongsTab({super.key});

  // Khởi tạo service xử lý dữ liệu
  static final SupabaseService _supabaseService = SupabaseService();

  // Biến notifier quản lý danh sách hiển thị cục bộ để ép re-render tức thì khi xóa
  static final ValueNotifier<List<BaiHatModel>> _favoriteSongsNotifier = ValueNotifier<List<BaiHatModel>>([]);

  // Hàm hiển thị tùy chọn Bottom Sheet khi nhấn vào 3 chấm (Giữ nguyên 100% UI của bạn)
  void _showMoreOptions(BuildContext context, BaiHatModel song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181818),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Thông tin bài hát thu nhỏ trong Bottom Sheet
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    song.imageURl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  song.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  song.artist,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(color: Colors.white10),

              // NÚT CHỨC NĂNG CHÍNH: Bỏ thích bài hát
              ListTile(
                leading: const Icon(Icons.favorite_rounded, color: Colors.grey),
                title: const Text(
                  'Xóa khỏi danh sách yêu thích',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                onTap: () async {
                  Navigator.pop(context); // Đóng Bottom Sheet trước

                  // 💡 ĐÂY RỒI: Xóa bài hát ra khỏi ValueNotifier ngay lập tức để ép UI render lại tại chỗ
                  _favoriteSongsNotifier.value = _favoriteSongsNotifier.value
                      .where((item) => item.id != song.id)
                      .toList();

                  try {
                    // Gọi hàm xử lý xóa khỏi bảng liked_songs ngầm dưới database
                    await _supabaseService.toggleLikeSong(song.id);

                    // Hiện thông báo nhỏ thông báo thành công
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã xóa "${song.title}" khỏi danh sách yêu thích'),
                        backgroundColor: Colors.purple,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.redAccent),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

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

    // Lấy dữ liệu lần đầu từ bảng liked_songs bằng FutureBuilder độc lập
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: supabase.from('liked_songs').select().eq('user_id', userId),
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

        final List<int> songIds = likedRecords.map((item) => item['song_id'] as int).toList();

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: supabase.from('songs').select(),
          builder: (context, songSnapshot) {
            if (songSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            final allSongs = songSnapshot.data ?? [];
            final List<BaiHatModel> favoriteSongs = allSongs
                .where((songMap) => songIds.contains(songMap['id'] as int))
                .map((json) => BaiHatModel.fromMap(json))
                .toList();

            // Đổ dữ liệu vào notifier ban đầu
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_favoriteSongsNotifier.value.isEmpty && favoriteSongs.isNotEmpty) {
                _favoriteSongsNotifier.value = favoriteSongs;
              }
            });

            // Lắng nghe sự thay đổi của danh sách để re-render ngay tức thì khi ấn nút xóa
            return ValueListenableBuilder<List<BaiHatModel>>(
              valueListenable: _favoriteSongsNotifier,
              builder: (context, displaySongs, child) {
                if (displaySongs.isEmpty) {
                  return const Center(
                    child: Text('Chưa có bài hát yêu thích nào', style: TextStyle(color: Colors.white54)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  itemCount: displaySongs.length,
                  itemBuilder: (context, index) {
                    final item = displaySongs[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NowPlayingScreen(
                                Baihat: item,
                                ListBaihat: displaySongs,
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

                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.more_vert, color: AppColors.primary),
                              onPressed: () {
                                _showMoreOptions(context, item);
                              },
                            ),
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
      },
    );
  }
}