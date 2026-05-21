import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:music_app/models/models_music.dart';
class AudioPlayerManager {
  AudioPlayerManager({required this.songURL}); 
  String songURL;
  final player = AudioPlayer();
  late Stream<DurationState> durationState;

  void init(){
    durationState = Rx.combineLatest2<Duration,PlaybackEvent, DurationState>(
      player.positionStream,
      player.playbackEventStream,
      (position, playbackEvent) =>
       DurationState(
        progress: position,
        buffered: playbackEvent.bufferedPosition,
        total: playbackEvent.duration));
    player.setUrl(songURL);
  }
  // void updateSongUrl(String url){
  //   songURL = url;
  //   init();
  //
  // }
  Future<void> updateSongUrl(String url) async {
    try {
      songURL = url;
      await player.stop(); // Dừng triệt để bài cũ để giải phóng luồng âm thanh
      await player.setUrl(url); // Nạp URL mới và đợi đệm xong
    } catch (e) {
      if (kDebugMode) {
        print("Lỗi khi chuyển bài hát: $e");
      }
    }
  }
}

class DurationState{
  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });
  final Duration progress;
  final Duration buffered;
  final Duration? total;

}