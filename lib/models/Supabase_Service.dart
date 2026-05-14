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
}