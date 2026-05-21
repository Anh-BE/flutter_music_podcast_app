import 'package:flutter/material.dart';
import '../../models/Supabase_Service.dart';
import '../../models/models_music.dart';
import '../../screen/play_song.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final PlaylistModel playlist;
  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  static final SupabaseService _service = SupabaseService();
  List<BaiHatModel> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylistSongs();
  }

  // Hàm tải danh sách bài hát
  Future<void> _loadPlaylistSongs() async {
    setState(() => _isLoading = true);
    final songs = await _service.getSongsInPlaylist(widget.playlist.id);
    setState(() {
      _songs = songs;
      _isLoading = false;
    });
  }

  // Xử lý xóa bài hát khỏi playlist
  void _deleteSong(int songId, String songTitle) async {
    final error = await _service.removeSongFromPlaylist(
      playlistId: widget.playlist.id,
      songId: songId,
    );

    if (context.mounted) {
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đã xóa '$songTitle' khỏi playlist")),
        );
        // Tải lại danh sách sau khi xóa thành công
        _loadPlaylistSongs();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Xóa thất bại: $error"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(widget.playlist.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF7B1E9D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7B1E9D), Color(0xFF121212)],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _songs.isEmpty
            ? const Center(
          child: Text(
            "Playlist này chưa có bài hát nào.\nHãy thêm bài hát từ trang chủ nhé!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 15),
          ),
        )
            : Column(
          children: [
            // Nút phát tất cả bài hát trong playlist
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NowPlayingScreen(
                        Baihat: _songs.first,
                        ListBaihat: _songs,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 28),
                label: const Text("PHÁT TẤT CẢ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            // Danh sách bài hát
            Expanded(
              child: ListView.builder(
                itemCount: _songs.length,
                itemBuilder: (context, index) {
                  final item = _songs[index];
                  return Card(
                    color: Colors.transparent,
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
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
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        item.artist,
                        style: const TextStyle(color: Colors.white54),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                        onPressed: () {
                          // Hiển thị hộp thoại xác nhận trước khi xóa
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFF2C2C2C),
                              title: const Text("Xóa khỏi Playlist?", style: TextStyle(color: Colors.white)),
                              content: Text("Bạn có chắc muốn xóa bài hát '${item.title}' ra khỏi danh sách phát này?", style: const TextStyle(color: Colors.white70)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Hủy", style: TextStyle(color: Colors.white54)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteSong(item.id, item.title);
                                  },
                                  child: const Text("Xóa", style: TextStyle(color: Colors.redAccent)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NowPlayingScreen(
                              Baihat: item,
                              ListBaihat: _songs,
                            ),
                          ),
                        );
                      },
                    ),
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