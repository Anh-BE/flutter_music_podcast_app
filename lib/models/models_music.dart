
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


