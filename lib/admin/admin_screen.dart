import 'package:flutter/material.dart';
import '../models/Supabase_Service.dart';
import '../colors/app_colors.dart';
import '../models/models_music.dart';
import 'manage_songs_screen.dart';
import 'manage_podcards_screen.dart';
import 'manage_albums_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseService = SupabaseService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Quản lý hệ thống Musify',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true, // Căn giữa tiêu đề
        iconTheme: const IconThemeData(color: Colors.white), // Đổi màu nút Back thành trắng
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 173, 7, 233), AppColors.background],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // --- 3 ROW QUẢN LÝ ---
            _buildManageRow(context, 'Quản lý Bài hát', Icons.music_note_rounded, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageSongsScreen()));
            }),
            const SizedBox(height: 16),
            _buildManageRow(context, 'Quản lý Album', Icons.album_rounded, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageAlbumsScreen()));
            }),
            const SizedBox(height: 16),
            _buildManageRow(context, 'Quản lý PodCard', Icons.podcasts_rounded, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ManagePodcardsScreen()));
            }),

            const SizedBox(height: 40),

            // --- TIÊU ĐỀ BẢNG THỐNG KÊ ---
            const Text(
              'Bảng Thống Kê ',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // --- BẢNG THỐNG KÊ HIỂN THỊ DỮ LIỆU ---
            _buildStatsBoard(supabaseService),
          ],
          ),
        ),
      ),
    );
  }

  // Hàm tiện ích tạo giao diện cho từng Row quản lý
  Widget _buildManageRow(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 73, 68, 72),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 178, 10, 239).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color.fromARGB(255, 180, 9, 242), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color.fromARGB(97, 231, 4, 227), size: 16),
          ],
        ),
      ),
    );
  }

  // Hàm tiện ích tạo Bảng thống kê (Lắng nghe Stream trực tiếp)
  Widget _buildStatsBoard(SupabaseService service) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 73, 68, 72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromARGB(255, 181, 10, 244).withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color.fromARGB(255, 182, 8, 245).withOpacity(0.05), blurRadius: 20, spreadRadius: 1),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Stream Bài hát
          StreamBuilder<List<BaiHatModel>>(
            stream: service.getSongsStream(),
            builder: (context, snapshot) => _buildStatItem('Bài Hát', snapshot.hasData ? snapshot.data!.length.toString() : '...', Icons.music_note_rounded),
          ),
          
          Container(width: 1, height: 40, color: Colors.white12),
          
          // Stream PodCard
          StreamBuilder<List<PodCardModel>>(
            stream: service.getPodcardStream(),
            builder: (context, snapshot) => _buildStatItem('PodCard', snapshot.hasData ? snapshot.data!.length.toString() : '...', Icons.podcasts_rounded),
          ),

          Container(width: 1, height: 40, color: Colors.white12),
          
          // Stream Album
          StreamBuilder<List<AlbumModel>>(
            stream: service.getAlbumsStream(),
            builder: (context, snapshot) => _buildStatItem('Album', snapshot.hasData ? snapshot.data!.length.toString() : '...', Icons.album_rounded),
          ),
        ],
      ),
    );
  }

  // Hàm tiện ích tạo từng cột số liệu thống kê
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color.fromARGB(255, 177, 10, 238), size: 28),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
      ],
    );
  }
}