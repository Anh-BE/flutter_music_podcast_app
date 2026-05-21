
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models_music.dart';
import '../models/models_userProfileModel.dart';



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




  Future<String?> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        // Đẩy tên người dùng vào dữ liệu siêu dữ liệu (metadata) để trigger tự bắt lấy
        data: {'username': username},
      );

      if (authResponse.user != null) {
        return null; // Thành công, không có lỗi
      }
      return 'Đăng ký thất bại, vui lòng thử lại';
    } catch (e) {
      return e.toString(); // Trả về chuỗi thông báo lỗi
    }
  }

  // 2. Logic Đăng nhập hệ thống
  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        return null; // Đăng nhập thành công
      }
      return 'Sai tài khoản hoặc mật khẩu';
    } catch (e) {
      return e.toString();
    }
  }

  // 3. Logic Đăng xuất
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // 4. Luồng dữ liệu (Stream) lắng nghe thông tin tài khoản hiện tại
  Stream<UserProfileModel?> get currentUserProfileStream {
    final user = _supabase.auth.currentUser;
    if (user == null) return Stream.value(null);

    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', user.id)
        .map((maps) {
      if (maps.isEmpty) return null;
      return UserProfileModel.fromJson(maps.first);
    });
  }
    Stream<List<PodCardModel>> getPodcardStream() {
    return _supabase
        .from('podcards')
        .stream(primaryKey: ['id'])
        .order('id')
        .map((data) => data.map((json) => PodCardModel.fromJson(json)).toList());

  }

//logic yêu thích bài hát
// Lấy ID của người dùng hiện tại đang đăng nhập hệ thống
  String? get currentUserId => _supabase.auth.currentUser?.id;
  // 1. Kiểm tra xem bài hát cụ thể này đã được User này thích chưa
  Future<bool> isSongLiked(dynamic songId) async {
    final userId = currentUserId;
    if (userId == null) return false;

    try {
      final response = await _supabase // Hết báo lỗi undefined
          .from('liked_songs')
          .select()
          .eq('user_id', userId)
          .eq('song_id', songId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print("Lỗi kiểm tra trạng thái tim: \$e");
      return false;
    }
  }

// 2. Xử lý Bấm Tim
  Future<bool> toggleLikeSong(dynamic songId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception("Vui lòng đăng nhập để thực hiện chức năng này");

    final isLiked = await isSongLiked(songId);

    try {
      if (isLiked) {
        await _supabase // Hết báo lỗi undefined
            .from('liked_songs')
            .delete()
            .eq('user_id', userId)
            .eq('song_id', songId);
        return false;
      } else {
        await _supabase.from('liked_songs').insert({ // Hết báo lỗi undefined
          'user_id': userId,
          'song_id': songId,
        });
        return true;
      }
    } catch (e) {
      print("Lỗi xử lý toggle like: \$e");
      rethrow;
    }
  }
  // 3. Lấy thông tin Profile kèm toàn bộ danh sách chi tiết bài hát đã thích
  Future<Map<String, dynamic>?> getProfileWithLikedSongs() async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      final response = await _supabase // Hết báo lỗi undefined
          .from('profiles')
          .select('''
            id,
            username,
            avatar_url,
            liked_songs (
              created_at,
              songs (*) 
            )
          ''')
          .eq('id', userId)
          .maybeSingle();

      return response as Map<String, dynamic>?;
    } catch (e) {
      print("Lỗi lấy thông tin Profile và bài hát đã thích: \$e");
      return null;
    }
  }





  // --- CÁC HÀM DÀNH CHO ADMIN (CRUD BÀI HÁT) ---

  // 1. Thêm bài hát
  Future<void> addSong({required String title, required String artist, required String imageUrl, required String audioUrl, int? albumId, required int duration}) async {
    await _supabase.from('songs').insert({
      'title': title,
      'artist': artist,
      'imageURl': imageUrl,
      'audioURL': audioUrl,
      'album_id': albumId,
      'duration': duration,
    });
  }

  // 2. Xóa bài hát
  Future<void> deleteSong(int id) async {
    await _supabase.from('songs').delete().eq('id', id);
  }

  // 3. Cập nhật bài hát
  Future<void> updateSong(int id, Map<String, dynamic> updates) async {
    // Ví dụ updates: {'title': 'Tên mới', 'artist': 'Ca sĩ mới'}
    await _supabase.from('songs').update(updates).eq('id', id);
  }



//các logic chức năng playlist
// 1. Luồng lắng nghe danh sách Playlist của User đang đăng nhập thời gian thực
  Stream<List<PlaylistModel>> getMyPlaylistsStream() {
    final user = _supabase.auth.currentUser;
    if (user == null) return Stream.value([]);

    return _supabase
        .from('playlists')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => PlaylistModel.fromJson(json)).toList());
  }

  // 2. Hàm tạo một Playlist trống mới
  Future<String?> createPlaylist(String name) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 'Bạn cần đăng nhập trước';

      await _supabase.from('playlists').insert({
        'name': name,
        'user_id': user.id,
      });
      return null; // Trả về null tức là thành công
    } catch (e) {
      return e.toString();
    }
  }

  // 3. Hàm chèn bài hát được chọn vào Playlist chỉ định
  Future<String?> addSongToPlaylist({required int playlistId, required int songId}) async {
    try {
      await _supabase.from('playlist_songs').insert({
        'playlist_id': playlistId,
        'song_id': songId,
      });
      return null;
    } catch (e) {
      if (e.toString().contains('duplicate key')) {
        return 'Bài hát này đã tồn tại trong playlist!';
      }
      return 'Lỗi: Không thể thêm bài hát';
    }
  }

// Lấy danh sách bài hát thuộc một Playlist cụ thể dựa vào playlistId
  Future<List<BaiHatModel>> getSongsInPlaylist(int playlistId) async {
    try {
      // Thực hiện Join từ bảng playlist_songs sang bảng songs để lấy thông tin bài hát
      final response = await _supabase
          .from('playlist_songs')
          .select('songs (*)') // Lấy tất cả các cột thuộc bảng songs liên kết
          .eq('playlist_id', playlistId);

      if (response == null) return [];

      final data = response as List<dynamic>;

      // Ánh xạ dữ liệu trả về thành danh sách BaiHatModel
      return data.map((item) {
        final songData = item['songs'] as Map<String, dynamic>;
        return BaiHatModel.fromMap(songData);
      }).toList();
    } catch (e) {
      print('Lỗi khi lấy bài hát trong playlist: $e');
      return [];
    }
  }
  // Hàm xóa một bài hát ra khỏi playlist dựa vào playlist_id và song_id
  Future<String?> removeSongFromPlaylist({required int playlistId, required int songId}) async {
    try {
      await _supabase
          .from('playlist_songs')
          .delete()
          .eq('playlist_id', playlistId)
          .eq('song_id', songId);
      return null; // Xóa thành công, không trả về lỗi
    } catch (e) {
      return e.toString();
    }
  }

}