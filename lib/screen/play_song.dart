import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:music_app/models/models_music.dart';
import 'audio_player.dart'; 
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key, required this.Baihat});
  
  final BaiHatModel Baihat;

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  late AudioPlayerManager _audioPlayerManager;

  @override
  void initState() {
    super.initState();
    _audioPlayerManager = AudioPlayerManager(songURL: widget.Baihat.audioURL); 
    _audioPlayerManager.init();
    _audioPlayerManager.player.play();
  }

  @override
  void dispose() {
    _audioPlayerManager.player.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final screeenwith = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(padding:EdgeInsets.symmetric(horizontal:8.0 ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed:() => Navigator.pop(context), 
                  icon: Icon(Icons.arrow_back,
                  size : 20) 
                 ),
                Text(
                  widget.Baihat.title,
                  style: TextStyle(
                    fontSize:18 ,
                  ),
                ),
              IconButton(onPressed:() => Navigator.pop(context),
               icon: Icon(Icons.more_horiz))
              ],
             ),
            
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 8.0,vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child:Image.network(
                  widget.Baihat.imageURl,
                  width: 310,
                  height: 310,
                  fit: BoxFit.cover), 
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 26),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.Baihat.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.Baihat.artist,
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ],  
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top:10 ,bottom:10 ,left:35 ,right:30 ),
          child: _progressBar()),
          Padding(padding: EdgeInsets.only(top:10 ,bottom:10 ,left:12 ,right:12 ),
          child: _mediaButtons()),
          ],
          
        ),
      ),
    );
  }

  Widget _mediaButtons() {
  return SizedBox(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const MediaButtonControl(
          function: null,
          icon: Icons.shuffle,
          color: Colors.deepPurple,
          size: 24,
        ),
        const MediaButtonControl(
          function: null,
          icon: Icons.skip_previous,
          color: Colors.deepPurple,
          size: 36,
        ),
        _playButton(),
        const MediaButtonControl(
          function: null,
          icon: Icons.skip_next,
          color: Colors.deepPurple,
          size: 36,
        ),
        const MediaButtonControl(
          function: null,
          icon: Icons.repeat,
          color: Colors.deepPurple,
          size: 24,
        ),
      ],
    ),
  );
}
  StreamBuilder<PlayerState> _playButton() {
  return StreamBuilder<PlayerState>(
    stream: _audioPlayerManager.player.playerStateStream,
    builder: (context, snapshot) {
      final playState = snapshot.data;
      final processingSate = playState?.processingState;
      final playing = playState?.playing;

      if (processingSate == ProcessingState.loading ||
          processingSate == ProcessingState.buffering) {
        return Container(
          margin: const EdgeInsets.all(8),
          width: 48,
          height: 48,
          child: const CircularProgressIndicator(),
        );
      } else if (playing != true) {
        return MediaButtonControl(
          function: () {
            _audioPlayerManager.player.play();
          },
          icon: Icons.play_arrow_sharp,
          color: null,
          size: 48,
        );
      } else if (processingSate != ProcessingState.completed) {
        return MediaButtonControl(
          function: () {
            _audioPlayerManager.player.pause();
          },
          icon: Icons.pause,
          color: null,
          size: 48,
        ); 
      } else {
        return MediaButtonControl(
          function: () {
            _audioPlayerManager.player.seek(Duration.zero);
          },
          icon: Icons.replay,
          color: null,
          size: 48,
        ); 
      }
    },
  ); 
}
  StreamBuilder<DurationState> _progressBar() {
  return StreamBuilder<DurationState>(
    stream: _audioPlayerManager.durationState,
    builder: (context, snapshot) {
      final durationState = snapshot.data;
      final progress = durationState?.progress ?? Duration.zero;
      final buffered = durationState?.buffered ?? Duration.zero;
      final total = durationState?.total ?? Duration.zero;
      
      return ProgressBar(
        progress: progress,
        buffered: buffered, 
        total: total,
        onSeek: _audioPlayerManager.player.seek,
      );
    },
  );
}
}

class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    required this.color,
    required this.size,
  });

  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;

  @override
  State<StatefulWidget> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ??Theme.of(context).colorScheme.primary,
    ); 
  }
}