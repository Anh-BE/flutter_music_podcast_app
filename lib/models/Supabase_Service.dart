
import 'dart:io';
import 'dart:typed_data';
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
      .from('songs')
      .stream(primaryKey: ['id'])
      .eq('album_id', albumId)
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
        data: {'username': username},
      );

      if (authResponse.user != null) {
        return null;
      }
      return 'Đăng ký thất bại, vui lòng thử lại';
    } catch (e) {
      return e.toString();
    }
  }

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
        return null;
      }
      return 'Sai tài khoản hoặc mật khẩu';
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

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

  String? get currentUserId => _supabase.auth.currentUser?.id;

  Future<bool> isSongLiked(dynamic songId) async {
    final userId = currentUserId;
    if (userId == null) return false;

    try {
      final response = await _supabase
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

  Future<bool> toggleLikeSong(dynamic songId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception("Vui lòng đăng nhập để thực hiện chức năng này");

    final isLiked = await isSongLiked(songId);

    try {
      if (isLiked) {
        await _supabase
            .from('liked_songs')
            .delete()
            .eq('user_id', userId)
            .eq('song_id', songId);
        return false;
      } else {
        await _supabase.from('liked_songs').insert({
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

  Future<Map<String, dynamic>?> getProfileWithLikedSongs() async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      final response = await _supabase
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

  Future<void> deleteSong(int id) async {
    await _supabase.from('songs').delete().eq('id', id);
  }

  Future<void> updateSong(int id, Map<String, dynamic> updates) async {
    await _supabase.from('songs').update(updates).eq('id', id);
  }

  Future<void> addPodcard({
    required String title,
    required String author,
    required String imagePodcardUrl,
    required String linkPodcardUrl,
    required int duration,
  }) async {
    await _supabase.from('podcards').insert({
      'title': title,
      'author': author,
      'image_podcard_URL': imagePodcardUrl,
      'link_podcard_URL': linkPodcardUrl,
      'duration': duration,
    });
  }

  Future<void> deletePodcard(int id) async {
    await _supabase.from('podcards').delete().eq('id', id);
  }

  Future<void> updatePodcard(int id, Map<String, dynamic> updates) async {
    await _supabase.from('podcards').update(updates).eq('id', id);
  }

  Future<void> addAlbum({
    required String title,
    required String artistAlbum,
    required String imageUrlAlbum,
  }) async {
    await _supabase.from('albums').insert({
      'title': title,
      'artist_album': artistAlbum,
      'imageURl_album': imageUrlAlbum,
    });
  }

  Future<void> deleteAlbum(int id) async {
    await _supabase.from('albums').delete().eq('id', id);
  }

  Future<void> updateAlbum(int id, Map<String, dynamic> updates) async {
    await _supabase.from('albums').update(updates).eq('id', id);
  }

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

  Future<String?> createPlaylist(String name) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 'Bạn cần đăng nhập trước';

      await _supabase.from('playlists').insert({
        'name': name,
        'user_id': user.id,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

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

  Future<List<BaiHatModel>> getSongsInPlaylist(int playlistId) async {
    try {
      final response = await _supabase
          .from('playlist_songs')
          .select('songs (*)')
          .eq('playlist_id', playlistId);

      if (response == null) return [];

      final data = response as List<dynamic>;

      return data.map((item) {
        final songData = item['songs'] as Map<String, dynamic>;
        return BaiHatModel.fromMap(songData);
      }).toList();
    } catch (e) {
      print('Lỗi khi lấy bài hát trong playlist: $e');
      return [];
    }
  }

  Future<String?> removeSongFromPlaylist({required int playlistId, required int songId}) async {
    try {
      await _supabase
          .from('playlist_songs')
          .delete()
          .eq('playlist_id', playlistId)
          .eq('song_id', songId);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deletePlaylist(int playlistId) async {
    try {
      await _supabase
          .from('playlists')
          .delete()
          .eq('id', playlistId);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> uploadFileToStorage(String bucketName, String path, {File? file, Uint8List? fileBytes}) async {
    try {
      if (fileBytes != null) {
        await _supabase.storage.from(bucketName).uploadBinary(path, fileBytes);
      } else if (file != null) {
        await _supabase.storage.from(bucketName).upload(path, file);
      } else {
        return null;
      }
      return _supabase.storage.from(bucketName).getPublicUrl(path);
    } catch (e) {
      print("Lỗi upload file: $e");
      return null;
    }
  }

}