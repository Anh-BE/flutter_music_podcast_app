
class BaiHatModel{
    String title,artist,imageURl,audioURL,album;
    int id;
    Duration duration;

  BaiHatModel({
    required this.id,
    required this.title,
    required this.imageURl,
    required this.artist,
    required this.audioURL,
    required this.album,
    required this.duration

  });
  factory BaiHatModel.fromMap(Map<String, dynamic> data) {
    return BaiHatModel(
      id: data['id'] , 
      title: data['title'] ?? 'chua co mo tieu de',
      artist: data['artist'] ?? 'Chưa có ca sĩ',
      imageURl: data['imageURl'] ?? 'chua co anh',
      audioURL: data['audioURL'] ?? 'link audio có vấn đề',
      album: data['album'] ?? '',
      duration: Duration(seconds: data['duration'] ?? 0),
    );


}
}
class AlbumModel {
  final int id;
  final String title;
  final String artistAlbum;
  final String imageUrlAlbum;

  AlbumModel({
    required this.id,
    required this.title,
    required this.artistAlbum,
    required this.imageUrlAlbum,
  });

  // Hàm chuyển đổi từ JSON (Supabase trả về) sang Object trong Flutter
  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id'] as int,
      title: json['title'] ?? 'Unknown Title',
      artistAlbum: json['artist_album'] ?? 'Unknown Artist',
      imageUrlAlbum: json['imageURl_album'] ?? 'https://your-placeholder-image-url.com', 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist_album': artistAlbum,
      'imageURl_album': imageUrlAlbum,
    };
  }

}

class PodCardModel {
  final int id;
  final String imagePodcardUrl;
  final String linkPodcardUrl;
  final int duration;
  final String author;
  final String title;

  PodCardModel({
    required this.id,
    required this.imagePodcardUrl,
    required this.linkPodcardUrl,
    required this.duration,
    required this.author,
    required this.title,
  });

  factory PodCardModel.fromJson(Map<String, dynamic> json) {
    return PodCardModel(
      id: json['id'] as int,
      imagePodcardUrl: json['image_podcard_URL'] as String? ?? '',
      linkPodcardUrl: json['link_podcard_URL'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      author: json['author'] as String? ?? 'Unknown',
      title: json['title'] as String? ?? 'No Title',
    );
  }
}
class PlaylistModel {
  final int id;
  final String name;
  final String userId;

  PlaylistModel({required this.id, required this.name, required this.userId});

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] as int,
      name: json['name'] ?? 'Playlist không tên',
      userId: json['user_id'] ?? '',
    );
  }
}