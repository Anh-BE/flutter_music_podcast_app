import 'package:flutter/material.dart';
import '../models/supabase_service.dart';
import '../models/models_music.dart';

class ListPodcastScreen extends StatelessWidget {
  final SupabaseService _service = SupabaseService();

  ListPodcastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Sử dụng gradient giống hệt màn hình List Songs
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7B1E9D), Color(0xFF121212)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 20.0, bottom: 20.0),
                child: Text(
                  "Khám Phá Podcast",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<PodcastModel>>(
                  stream: _service.getPodcardStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Lỗi tải Podcast: ${snapshot.error}",
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final podcasts = snapshot.data ?? [];
                    if (podcasts.isEmpty) {
                      return const Center(
                        child: Text(
                          "Chưa có Podcast nào được thêm.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: podcasts.length,
                      itemBuilder: (context, index) {
                        final item = podcasts[index];
                        return _buildPodcastBigCard(item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm bổ trợ để vẽ Thẻ Podcast Lớn (Big Card) giống y chang ảnh mẫu
  Widget _buildPodcastBigCard(PodcastModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Khối ảnh/video lớn tỉ lệ 16:9
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imagePodcardUrl,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.podcasts, color: Colors.white, size: 50),
                ),
              ),
            ),
          ),
          // Hàng thông tin chi tiết phía dưới
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                item.imagePodcardUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 40,
                  height: 40,
                  color: Colors.grey[800],
                  child: const Icon(Icons.music_note, color: Colors.white),
                ),
              ),
            ),
            title: Text(
              item.title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${item.author} • ${item.duration} giây',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.more_vert, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}