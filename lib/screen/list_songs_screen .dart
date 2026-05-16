import 'package:flutter/material.dart';
import 'package:music_app/models/Supabase_Service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models_music.dart';
import 'play_song.dart';

class ListSongsScreen extends StatelessWidget {
  final SupabaseService _service = SupabaseService();
  ListSongsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Danh Sách Nhạc")),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7B1E9D), Color(0xFF121212)],
          ),
        ),
        child: StreamBuilder<List<BaiHatModel>>(
          stream: _service.getSongsStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Lỗi: ${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final songs = snapshot.data ?? [];
            if (songs.isEmpty) {
              return const Center(
                child: Text("Không có bài hát nào (Hoặc bị chặn RLS)."),
              );
            }
            return ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final item = songs[index];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        item.imageURl,
                        width: 50,
                        errorBuilder: (c, e, s) => const Icon(Icons.music_note),
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        color: const Color.fromARGB(221, 247, 246, 246),
                      ),
                    ),
                    subtitle: Text(
                      item.artist,
                      style: TextStyle(
                        color: const Color.fromARGB(137, 245, 244, 244),
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
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
