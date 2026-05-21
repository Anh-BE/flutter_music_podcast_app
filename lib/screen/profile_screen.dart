
import '../colors/app_colors.dart';
import 'package:flutter/material.dart';
import '../models/Supabase_Service.dart';
import '../models/models_userProfileModel.dart';
import 'sign_in_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseService = SupabaseService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // LOGO TÍCH HỢP TRÊN THANH TIÊU ĐỀ
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.music_note_rounded, color: AppColors.button, size: 22),
            SizedBox(width: 6),
            Text('Musify Profile', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<UserProfileModel?>(
        stream: supabaseService.currentUserProfileStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final profile = snapshot.data;
          if (profile == null) {
            return const Center(child: Text('Không tìm thấy thông tin hồ sơ', style: TextStyle(color: AppColors.textWhite)));
          }

          // LỒNG FUTUREBUILDER: Để đồng bộ lấy thêm danh sách bài hát yêu thích
          return FutureBuilder<Map<String, dynamic>?>(
            future: supabaseService.getProfileWithLikedSongs(),
            builder: (context, likedSnapshot) {
              int likedSongsCount = 0;
              List<dynamic> likedSongsList = [];

              if (likedSnapshot.hasData && likedSnapshot.data != null) {
                final likedSongsRaw = likedSnapshot.data!['liked_songs'] as List? ?? [];
                likedSongsList = likedSongsRaw
                    .map((item) => item['songs'] as Map<String, dynamic>?)
                    .where((song) => song != null)
                    .toList();
                likedSongsCount = likedSongsList.length;
              }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Vòng tròn bao bọc Avatar
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.button, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        profile.avatarUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(color: AppColors.button)),
                        errorBuilder: (context, err, stack) => Container(color: const Color(0xFF222222), child: const Icon(Icons.person, color: AppColors.textGrey, size: 50)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tên hiển thị người dùng (Màu trắng chính)
                Text(profile.username, style: const TextStyle(color: AppColors.textWhite, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                // Ngày tham gia (Màu xám mờ đồng bộ cấu hình)
                Text('Thành viên từ: ${profile.createdAt.day}/${profile.createdAt.month}/${profile.createdAt.year}', style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),

                const SizedBox(height: 35),

                // Khối thông số nghe nhạc
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.03)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [

                      _buildStatItem('Playlists', '0'),
                      Container(width: 1, height: 35, color: Colors.white10),
                      _buildStatItem('Yêu thích', '$likedSongsCount'),
                    ],
                  ),
                ),
                const SizedBox(height: 45),

                // Nút Đăng Xuất tinh giản
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton(
                    onPressed: () async {
                      await supabaseService.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SignInScreen()), (route) => false);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent, width: 1.2),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                        SizedBox(width: 8),
                        Text("Đăng Xuất", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 12)),
      ],
    );
  }
}