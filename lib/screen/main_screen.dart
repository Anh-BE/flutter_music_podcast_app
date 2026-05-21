import 'package:flutter/material.dart';
import 'list_songs_screen .dart'; // Đã xóa khoảng trắng thừa ở đây
import 'search_screen.dart';
import 'list_podcards_screen.dart';
import '../screen/profile_screen.dart';
import '../screen/library_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // GIẢI PHÁP: Sử dụng hàm buildBody để lười tải (Lazy Loading)
  // Chỉ khi bấm vào Tab nào, Flutter mới nhảy vào file đó để dịch và chạy.
  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return ListSongsScreen(); // Chỉ load khi chọn "Trang chủ"
      case 1:
        return const SearchScreen(); // Chỉ load khi chọn "Tìm kiếm"
      case 2:
        return ListPodcastScreen(); // Chỉ load khi chọn "PodCards" (Đã sửa đúng tên Class)
      case 3:
        return ProfileScreen();
      case 4:
        return const LibraryScreen();
      default:
        return ListSongsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      
      // Sử dụng Column ở body để xếp chồng: Màn hình chính -> Thanh phát nhạc -> Menu dưới
      body: Column(
        children: [
          // 1. Giao diện chính của Tab chiếm hết khoảng trống còn lại
          Expanded(
            child: _buildBody(_selectedIndex), // Thay mảng cũ bằng hàm _buildBody ở đây
          ),
          
          // 2. NƠI ĐẶT MINI-PLAYER (Thanh bài hát/podcast đang phát giống Spotify)
          
        ],
      ),

      // 3. Thanh điều hướng dưới cùng được bọc trong SafeArea
      bottomNavigationBar: SafeArea(
        top: false, // Chỉ cần bảo vệ vùng đáy (bottom)
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF181818),
          selectedItemColor: const Color(0xFF7B1E9D),
          unselectedItemColor: Colors.white54,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          elevation: 0, // Tắt bóng mặc định nếu muốn tiệp màu hoàn toàn
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Trang chủ'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
            BottomNavigationBarItem(icon: Icon(Icons.library_music_outlined), label: 'PodCards'),
            BottomNavigationBarItem(icon: Icon(Icons.supervised_user_circle), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.audio_file_rounded), label: 'Library'),
          ],
        ),
      ),
    );
  }
}