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