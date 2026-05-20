import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models_music.dart';


class SupabaseService {
  final _supabase = Supabase.instance.client;

  Stream<List<BaiHatModel>> getSongsStream() {
    return _supabase
        .from('songs')
        .stream(primaryKey: ['id'])
        .order('id')
        .map((data) => data.map((json) => BaiHatModel.fromMap(json)).toList());
  }
  Stream<List<AlbumModel>> getAlbumsStream() {
    return _supabase
        .from('albums') 
        .stream(primaryKey: ['id'])
        .order('id') 
        .map((data) => data.map((json) => AlbumModel.fromJson(json)).toList());
  }

  Stream<List<BaiHatModel>> getSongsByAlbumIdStream(int albumId) {
  return _supabase
      .from('songs') // Truy vấn bảng bài hát
      .stream(primaryKey: ['id'])
      .eq('album_id', albumId) // 💡 Lọc: Cột 'album_id' trong DB phải bằng với 'albumId' truyền vào
      .order('id')
      .map((data) => data.map((json) => BaiHatModel.fromMap(json)).toList());
}
}