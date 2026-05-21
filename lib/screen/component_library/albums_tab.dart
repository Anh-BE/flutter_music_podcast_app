import 'package:flutter/material.dart';

class AlbumsTab extends StatelessWidget {
  const AlbumsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final int totalItems = 4; // Tạm thời để hardcode dữ liệu mẫu giống code cũ của bạn

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: (totalItems / 2).ceil(),
      itemBuilder: (context, rowIndex) {
        int firstIndex = rowIndex * 2;
        int secondIndex = firstIndex + 1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildSingleAlbumItem(firstIndex),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: secondIndex < totalItems
                    ? _buildSingleAlbumItem(secondIndex)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSingleAlbumItem(int index) {
    return InkWell(
      onTap: () {
        // Logic mở nhanh danh sách bài hát trong Album sau này
      },
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://via.placeholder.com/150',
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: const Color(0xFF2E2E2E),
                  child: const Icon(Icons.album, color: Colors.white54, size: 40),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tên Album #$index',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            'Album • Musify Artist',
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}