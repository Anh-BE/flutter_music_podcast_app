import 'package:flutter/material.dart';
import '../colors/app_colors.dart'; // Đồng bộ bảng màu hệ thống
import 'component_library/songs_tab.dart';
import 'component_library/playlists_tab.dart';
import 'component_library/albums_tab.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  // Quản lý tab đang chọn (0: Songs, 1: Playlists, 2: Albums)
  int _selectedTabCategory = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP HEADER (Avatar, Title, Search & Add Icons)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  // Ảnh Đại Diện User (Tròn)
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    backgroundImage: NetworkImage(
                      'https://bwcygbzraxmilppnwxhg.supabase.co/storage/v1/object/public/music_assets/user-default.jpg',
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Tiêu đề Trang
                  const Text(
                    'Thư viện',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // const Spacer(),
                  // // Các nút chức năng góc phải
                  // IconButton(
                  //   icon: const Icon(Icons.search, color: Colors.white, size: 26),
                  //   onPressed: () {
                  //     // Logic mở nhanh tìm kiếm trong thư viện
                  //   },
                  // ),
                  // IconButton(
                  //   icon: const Icon(Icons.add, color: Colors.white, size: 28),
                  //   onPressed: () {
                  //     // Logic tạo nhanh playlist mới
                  //   },
                  // ),
                ],
              ),
            ),

            // 2. CHIPS CATEGORY TABS (Thanh lọc danh mục dạng bo tròn giống mẫu)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: Row(
                  children: [
                    _buildCategoryChip(index: 0, label: 'Bài hát'),
                    _buildCategoryChip(index: 1, label: 'Playlist'),
                    _buildCategoryChip(index: 2, label: 'Album'),
                  ],
                ),
              ),
            ),

            const Divider(color: Colors.white10, height: 1),

            // 3. DYNAMIC CONTENT AREA
            Expanded(
              child: IndexedStack(
                index: _selectedTabCategory,
                children: [
                  SongsTab(),     // Gọi Tab Bài hát
                  PlaylistsTab(), // Gọi Tab Playlist
                  AlbumsTab(),    // Gọi Tab Album (Rất sạch sẽ!)

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget build các nút Tab dạng Chip lọc
  Widget _buildCategoryChip({required int index, required String label}) {
    final bool isSelected = _selectedTabCategory == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabCategory = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFF242424),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }}

