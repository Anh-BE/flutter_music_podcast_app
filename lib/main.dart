
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screen/welcome_screen.dart';
import 'screen/list_songs_screen .dart';
import 'screen/play_song.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bwcygbzraxmilppnwxhg.supabase.co', 
    anonKey: 'sb_publishable_BnbcrT7eOjdftju9nHlRKA_vmBT2Z1Q', 
  );

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ListSongsScreen(),
    );
  }
}