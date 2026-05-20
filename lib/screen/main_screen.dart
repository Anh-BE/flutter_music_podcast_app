import 'package:flutter/material.dart';
import 'list_songs_screen .dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    ListSongsScreen(), 
    const Center(child: Text('Tìm kiếm', style: TextStyle(color: Colors.white, fontSize: 24))), 
    const Center(child: Text('Thư viện', style: TextStyle(color: Colors.white, fontSize: 24))),
    const ProfileScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
            child: _screens[_selectedIndex],
          ),
          
          // 2. NƠI ĐẶT MINI-PLAYER (Thanh bài hát đang phát giống Spotify)
          // Hiện tại làm tạm một container giả lập, sau này bạn thiết kế widget player vào đây
          
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
            BottomNavigationBarItem(icon: Icon(Icons.library_music_outlined), label: 'Thư viện'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}