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
      body: StreamBuilder<List<BaiHatModel>>(
        stream: _service.getSongsStream(), 
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}", textAlign: TextAlign.center));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final songs = snapshot.data ?? [];
          if (songs.isEmpty) {
            return const Center(child: Text("Không có bài hát nào (Hoặc bị chặn RLS)."));
          }
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final item = songs[index];
              return ListTile(
                leading: Image.network(item.imageURl, width: 50, errorBuilder: (c, e, s) => const Icon(Icons.music_note)),
                title: Text(item.title),
                subtitle: Text(item.artist),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NowPlayingScreen(Baihat: item),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}