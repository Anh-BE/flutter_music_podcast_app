import 'dart:math';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:music_app/models/models_music.dart';
import 'audio_player.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({
    super.key,
    required this.Baihat,
    required this.ListBaihat,
  });

  final BaiHatModel Baihat;
  final List<BaiHatModel> ListBaihat;

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  late AudioPlayerManager _audioPlayerManager;
  late int _selectItemIndex;
  late BaiHatModel _song;
  double _currentAnimationPosition = 0.0;
  bool _isShuffle = false;
  LoopMode _loopMode = LoopMode.off;

  @override
  void initState() {
    super.initState();
    _song = widget.Baihat;
    _audioPlayerManager = AudioPlayerManager(songURL: _song.audioURL);
    _audioPlayerManager.init();
    _audioPlayerManager.player.play();
    _selectItemIndex = widget.ListBaihat.indexOf(widget.Baihat);
  }

  @override
  void dispose() {
    _audioPlayerManager.player.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final screeenwith = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7B1E9D), Color(0xFF121212)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: const Color.fromARGB(255, 216, 119, 243),
                      ),
                    ),
                    Text(
                      _song.title,
                      style: TextStyle(
                        fontSize: 18,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.more_horiz,
                        color: const Color.fromARGB(255, 213, 127, 244),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        _song.imageURl,
                        width: 310,
                        height: 310,
                        fit: BoxFit.cover,
                      ),
                    ),
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
                        _song.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _song.artist,
                        style: TextStyle(fontSize: 13, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  left: 35,
                  right: 30,
                ),
                child: _progressBar(),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  left: 12,
                  right: 12,
                ),
                child: _mediaButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mediaButtons() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(
            function: _setShuffle,
            icon: Icons.shuffle,
            color: _isShuffle
                ? const Color.fromARGB(255, 216, 119, 243)
                : const Color.fromARGB(255, 245, 244, 247),
            size: 24,
          ),
          MediaButtonControl(
            function: previousSong,
            icon: Icons.skip_previous,
            color: Color.fromARGB(255, 247, 247, 248),
            size: 36,
          ),
          _playButton(),
          MediaButtonControl(
            function: nextSong,
            icon: Icons.skip_next,
            color: Color.fromARGB(255, 249, 249, 250),
            size: 36,
          ),
          MediaButtonControl(
            function: setupRepeatOption,
            icon: _repeatingIcon(),
            color: _loopMode != LoopMode.off
                ? const Color.fromARGB(255, 216, 119, 243)
                : const Color.fromARGB(255, 245, 244, 247),
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
            color: const Color.fromARGB(255, 251, 251, 250),
            size: 48,
          );
        } else if (processingSate != ProcessingState.completed) {
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.pause();
            },
            icon: Icons.pause,
            color: const Color.fromARGB(255, 251, 251, 250),
            size: 48,
          );
        } else {
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.seek(Duration.zero);
            },
            icon: Icons.replay,
            color: const Color.fromARGB(255, 251, 251, 250),
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
          progressBarColor: Colors.white,
          baseBarColor: Colors.white24,
          bufferedBarColor: Colors.white38,
          thumbColor: Colors.white,

          timeLabelTextStyle: const TextStyle(color: Colors.white),
          onSeek: _audioPlayerManager.player.seek,
        );
      },
    );
  }

  void _setShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
    });
  }

  void nextSong() {
    if (_isShuffle) {
      var random = Random();
      _selectItemIndex = random.nextInt(widget.ListBaihat.length);
    } else if (_selectItemIndex < widget.ListBaihat.length - 1) {
      ++_selectItemIndex;
    } else if (_loopMode == LoopMode.all &&
        _selectItemIndex == widget.ListBaihat.length - 1) {
      _selectItemIndex = 0;
    }

    if (_selectItemIndex >= widget.ListBaihat.length) {
      _selectItemIndex = _selectItemIndex % widget.ListBaihat.length;
    }

    final nextSong = widget.ListBaihat[_selectItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.audioURL);

    setState(() {
      _song = nextSong;
    });
  }

  void previousSong() {
    if (_isShuffle) {
      var random = Random();

      _selectItemIndex = random.nextInt(widget.ListBaihat.length);
    } else if (_selectItemIndex > 0) {
      _selectItemIndex--;
    } else if (_loopMode == LoopMode.all && _selectItemIndex == 0) {
      _selectItemIndex = widget.ListBaihat.length - 1;
    }

    if (_selectItemIndex < 0) {
      _selectItemIndex = (-1 * _selectItemIndex) % widget.ListBaihat.length;
    }

    final previousSong = widget.ListBaihat[_selectItemIndex];

    _audioPlayerManager.updateSongUrl(previousSong.audioURL);

    _audioPlayerManager.player.play();

    setState(() {
      _song = previousSong;
    });
  }

  void setupRepeatOption() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.one;
    } else if (_loopMode == LoopMode.one) {
      _loopMode = LoopMode.all;
    } else {
      _loopMode = LoopMode.off;
    }

    setState(() {
      _audioPlayerManager.player.setLoopMode(_loopMode);
    });
  }

  IconData _repeatingIcon() {
    switch (_loopMode) {
      case LoopMode.one:
        return Icons.repeat_one;
      case LoopMode.all:
        return Icons.repeat_on;
      default:
        return Icons.repeat;
    }
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
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
