import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../models/Supabase_Service.dart';
import '../models/models_music.dart';
import 'play_song.dart';
import 'play_podcast_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SupabaseService _service = SupabaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              // Dùng mã màu trực tiếp để tránh lỗi null nếu AppColors chưa định nghĩa
              colors: [Color(0xFF7B1E9D), Color(0xFF121212)],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ô tìm kiếm
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    cursorColor: const Color(0xFF1DB954), // Con trỏ chuột màu xanh Spotify
                    decoration: InputDecoration(
                      hintText: 'Bạn muốn nghe gì?',
                      hintStyle: const TextStyle(color: Colors.white54, fontSize: 16),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 28),
                      // Nút xóa nhanh text khi đang gõ
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color.fromARGB(255, 73, 68, 72), // Màu xám đen đặc trưng của Spotify
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0), // Khung bo góc nhẹ (vuông hơn)
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                    ),
                  ),
                ),

                // Thanh TabBar phân chia Nhạc và Podcast
                const TabBar(
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  tabs: [
                    Tab(text: "Bài hát"),
                    Tab(text: "Podcast"),
                  ],
                ),

                // Hiển thị danh sách kết quả theo từng Tab
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildSongSearchResults(),
                      _buildPodcastSearchResults(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Tab Kết quả Bài Hát
  Widget _buildSongSearchResults() {
    return StreamBuilder<List<BaiHatModel>>(
      stream: _service.getSongsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }

        final songs = snapshot.data ?? [];
        // Bộ lọc Real-time
        final filteredSongs = _searchQuery.isEmpty
            ? songs
            : songs.where((song) =>
                song.title.toLowerCase().contains(_searchQuery) ||
                song.artist.toLowerCase().contains(_searchQuery)).toList();

        if (filteredSongs.isEmpty) {
          return const Center(child: Text("Không tìm thấy bài hát nào.", style: TextStyle(color: Colors.white70)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredSongs.length,
          itemBuilder: (context, index) {
            final item = filteredSongs[index];
            return _buildResultTile(
              imageUrl: item.imageURl,
              title: item.title,
              subtitle: item.artist,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NowPlayingScreen(Baihat: item, ListBaihat: filteredSongs))),
            );
          },
        );
      },
    );
  }

  // Tab Kết quả Podcast
  Widget _buildPodcastSearchResults() {
    return StreamBuilder<List<PodCardModel>>(
      stream: _service.getPodcardStream().cast<List<PodCardModel>>(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }

        final podcasts = snapshot.data ?? [];
        // Bộ lọc Real-time
        final filteredPodcasts = _searchQuery.isEmpty
            ? podcasts
            : podcasts.where((pod) =>
                pod.title.toLowerCase().contains(_searchQuery) ||
                pod.author.toLowerCase().contains(_searchQuery)).toList();

        if (filteredPodcasts.isEmpty) {
          return const Center(child: Text("Không tìm thấy podcast nào.", style: TextStyle(color: Colors.white70)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredPodcasts.length,
          itemBuilder: (context, index) {
            final item = filteredPodcasts[index];
            return _buildResultTile(
              imageUrl: item.imagePodcardUrl,
              title: item.title,
              subtitle: item.author,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayPodcastScreen(podcast: item))),
            );
          },
        );
      },
    );
  }

  // Component chung để vẽ Item cho đẹp và tái sử dụng
  Widget _buildResultTile({required String imageUrl, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.network(
          imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(
            width: 50, height: 50, color: Colors.grey[800],
            child: const Icon(Icons.music_note, color: Colors.white),
          ),
        ),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54), maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}