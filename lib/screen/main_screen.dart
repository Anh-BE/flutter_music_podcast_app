import 'package:flutter/material.dart';
import 'list_songs_screen .dart';
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

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return ListSongsScreen();
      case 1:
        return const SearchScreen();
      case 2:
        return ListPodcastScreen();
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
      
      body: Column(
        children: [
          Expanded(
            child: _buildBody(_selectedIndex),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF181818),
          selectedItemColor: const Color(0xFF7B1E9D),
          unselectedItemColor: Colors.white54,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          elevation: 0,
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