
import 'package:flutter/material.dart';
import 'package:music_app/colors/app_colors.dart';
import '../models/Supabase_Service.dart';
import '../models/models_music.dart';

import 'play_song.dart';
import 'album_songs_screen.dart';

class ListSongsScreen extends StatelessWidget {
  final SupabaseService _service = SupabaseService();
  ListSongsScreen({super.key});

  // Hàm hiển thị danh sách Playlist dưới đáy màn hình để người dùng thêm bài hát vào
  void _showAddToPlaylistBottomSheet(BuildContext context, int songId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Thêm vào Playlist",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              Flexible(
                child: StreamBuilder<List<PlaylistModel>>(
                  stream: _service.getMyPlaylistsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.purple)));
                    }

                    // Trường hợp CHƯA CÓ PLAYLIST NÀO
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            "Hiện chưa có playlist nào. Hãy tạo playlist ở tab Thư viện trước nhé!",
                            textAlign:TextAlign.center,
                            style: TextStyle(color: Colors.white60, fontSize: 14),
                          ),
                        ),
                      );
                    }

                    final playlists = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: playlists.length,
                      itemBuilder: (context, idx) {
                        final playlist = playlists[idx];
                        return ListTile(
                          leading: const Icon(Icons.playlist_add_check, color: Colors.purpleAccent),
                          title: Text(playlist.name, style: const TextStyle(color: Colors.white)),
                          onTap: () async {
                            Navigator.pop(context); // Đóng BottomSheet lại trước

                            final error = await _service.addSongToPlaylist(
                              playlistId: playlist.id,
                              songId: songId,
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error ?? "Đã thêm bài hát vào playlist '${playlist.name}' thành công!"),
                                  backgroundColor: error != null ? Colors.redAccent : Colors.green,
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7B1E9D), Color(0xFF121212)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 20.0, bottom: 10.0),
                child: Text(
                  "Album Nổi Bật",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              StreamBuilder<List<AlbumModel>>(
                stream: _service.getAlbumsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Lỗi Album: ${snapshot.error}",
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final albums = snapshot.data ?? [];
                  if (albums.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Không có album nào.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                  return SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: albums.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemBuilder: (context, index) {
                        final album = albums[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AlbumSongsScreen(album: album),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    album.imageUrlAlbum,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      width: 120,
                                      height: 120,
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.album, color: Colors.white, size: 50),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    album.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 20.0, bottom: 10.0),
                child: Text(
                  "Bài Hát",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              StreamBuilder<List<BaiHatModel>>(
                stream: _service.getSongsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Lỗi: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final songs = snapshot.data ?? [];
                  if (songs.isEmpty) {
                    return const Center(
                      child: Text(
                        "Không có bài hát nào (Hoặc bị chặn RLS).",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: songs.length ,
                    itemBuilder: (context, index) {
                      final item = songs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.network(
                              item.imageURl,
                              width: 50,
                              height: 50,
                              errorBuilder: (c, e, s) => const Icon(Icons.music_note, color: Colors.white),
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            item.title,
                            style: const TextStyle(
                              color: Color.fromARGB(221, 247, 246, 246),
                            ),
                          ),
                          subtitle: Text(
                            item.artist,
                            style: const TextStyle(
                              color: Color.fromARGB(137, 245, 244, 244),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    NowPlayingScreen(Baihat: item, ListBaihat: songs),
                              ),
                            );
                          },
                          // NÚT MỞ RỘNG Ở ĐÂY
                          trailing: IconButton(
                            icon: const Icon(Icons.more_vert, color:AppColors.primary),
                            onPressed: () {
                              _showAddToPlaylistBottomSheet(context, item.id);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


