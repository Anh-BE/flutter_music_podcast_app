import 'package:flutter/material.dart';
import '../models/models_music.dart';
import '../models/supabase_service.dart';
import 'play_song.dart';

class AlbumSongsScreen extends StatelessWidget {
  final AlbumModel album;
  final SupabaseService _service = SupabaseService();

  AlbumSongsScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          // Kế thừa phong cách màu nền Gradient từ ListSongsScreen
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7B1E9D), Color(0xFF121212)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 320.0, // Độ cao của phần hiển thị ảnh Album
              pinned: true,          // Giữ AppBar lại khi cuộn xuống
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  // Tính toán độ cao để biết người dùng đã cuộn qua ảnh chưa
                  final double collapsedHeight =
                      kToolbarHeight + MediaQuery.of(context).padding.top;
                  final bool isCollapsed =
                      constraints.maxHeight <= collapsedHeight + 40;

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Tạo một lớp nền solid kèm đường gạch ngang xuất hiện khi cuộn lên
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isCollapsed ? 1.0 : 0.0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF7B1E9D), // Màu tím khớp với nền gradient trên cùng
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white30, // Đường kẻ mờ ngăn cách
                                width: 1.0,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black45,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      FlexibleSpaceBar(
                        centerTitle: true,
                        // Hiệu ứng mờ dần hiển thị tên album khi cuộn lên che ảnh
                        title: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isCollapsed ? 1.0 : 0.0,
                          child: Text(
                            album.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        background: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 50),
                            // Ảnh Album
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                album.imageUrlAlbum,
                                width: 180,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  width: 180,
                                  height: 180,
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.album, color: Colors.white, size: 80),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            // Tên Album
                            Text(
                              album.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            // Tên ca sĩ
                            Text(
                              album.artistAlbum,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            // Phần hiển thị danh sách bài hát bên dưới
            SliverToBoxAdapter(
              child: StreamBuilder<List<BaiHatModel>>(
                stream: _service.getSongsByAlbumIdStream(album.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          "Lỗi: ${snapshot.error}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  final songs = snapshot.data ?? [];
                  
                  if (songs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          "Không có bài hát nào trong album này.",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    );
                  }

                  // Render danh sách bài hát giống phong cách ListSongsScreen
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 50),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final item = songs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.network(
                              item.imageURl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(Icons.music_note, color: Colors.white),
                            ),
                          ),
                          title: Text(
                            item.title,
                            style: const TextStyle(
                              color: Color.fromARGB(221, 247, 246, 246),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            item.artist,
                            style: const TextStyle(
                              color: Color.fromARGB(137, 245, 244, 244),
                            ),
                          ),
                          trailing: const Icon(Icons.more_vert, color: Colors.white54),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NowPlayingScreen(
                                  Baihat: item, 
                                  ListBaihat: songs
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
