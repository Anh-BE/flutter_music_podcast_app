import 'dart:math';
import '../models/Supabase_Service.dart';
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
  bool _isChangingSong = false; // Cờ kiểm soát tránh chuyển bài bị lặp/đụng độ

  // Khởi tạo các biến cho chức năng yêu thích
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _song = widget.Baihat;
    _audioPlayerManager = AudioPlayerManager(songURL: _song.audioURL);
    _audioPlayerManager.init();
    _audioPlayerManager.player.playerStateStream.listen((playerState) {
      final isCompleted = playerState.processingState == ProcessingState.completed;

      // Thêm điều kiện !_isChangingSong để không bị gọi next liên tục
      if (isCompleted && !_isChangingSong) {
        if (_loopMode != LoopMode.one) {
          _nextSong();
        } else {
          _audioPlayerManager.player.seek(Duration.zero);
          _audioPlayerManager.player.play();
        }
      }
    });
    _audioPlayerManager.player.play();
    _selectItemIndex = widget.ListBaihat.indexOf(widget.Baihat);
    _checkLikeStatus();


  }

  @override
  void dispose() {
    _audioPlayerManager.player.dispose();
    super.dispose();
  }

  // Hàm quét trạng thái thích từ Supabase
  void _checkLikeStatus() async {
    bool liked = await _supabaseService.isSongLiked(_song.id); // Giả định model của bạn dùng thuộc tính .id
    if (mounted) {
      setState(() {
        _isLiked = liked;
      });
    }
  }

  // Hàm xử lý khi nhấn vào nút Tim
  void _toggleLike() async {
    try {
      bool newStatus = await _supabaseService.toggleLikeSong(_song.id);
      setState(() {
        _isLiked = newStatus;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 30, color: Colors.white),
                    ),
                    const Text(
                      "ĐANG PHÁT BÀI HÁT",
                      style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Ảnh Bài hát
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      _song.imageURl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.music_note, size: 100, color: Colors.white54),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Thông tin bài hát
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _song.title,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _song.artist,
                            style: const TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _toggleLike,
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.redAccent : Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Thanh tiến trình
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                child: _progressBar(),
              ),
              
              // Các nút điều khiển
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0, left: 16.0, right: 16.0),
                child: _mediaButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mediaButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: _setShuffle,
          icon: Icon(
            Icons.shuffle,
            color: _isShuffle ? Colors.greenAccent : Colors.white54,
            size: 28,
          ),
        ),
        IconButton(
          onPressed: _previousSong,
          icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
        ),
        _playButton(),
        IconButton(
          onPressed: _nextSong,
          icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
        ),
        IconButton(
          onPressed: setupRepeatOption,
          icon: Icon(
            _repeatingIcon(),
            color: _loopMode != LoopMode.off ? Colors.greenAccent : Colors.white54,
            size: 28,
          ),
        ),
      ],
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
          return IconButton(
            iconSize: 64,
            icon: const Icon(Icons.play_circle_fill, color: Colors.white),
            onPressed: () => _audioPlayerManager.player.play(),
          );
        } else if (processingSate != ProcessingState.completed) {
          return IconButton(
            iconSize: 64,
            icon: const Icon(Icons.pause_circle_filled, color: Colors.white),
            onPressed: () => _audioPlayerManager.player.pause(),
          );
        } else {
          return IconButton(
            iconSize: 64,
            icon: const Icon(Icons.replay_circle_filled, color: Colors.white),
            onPressed: () => _audioPlayerManager.player.seek(Duration.zero),
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


  // Thêm async vào đầu hàm
  void _nextSong() async {
    // Nếu danh sách trống hoặc ĐANG CHUYỂN BÀI thì không làm gì cả
    if (widget.ListBaihat.isEmpty || _isChangingSong) return;

    if (mounted) {
      setState(() => _isChangingSong = true); // Khóa tiến trình chuyển bài
    }

    try {
      if (_isShuffle) {
        _selectItemIndex = Random().nextInt(widget.ListBaihat.length);
      } else {
        _selectItemIndex = (_selectItemIndex + 1) % widget.ListBaihat.length;
      }

      final nextSong = widget.ListBaihat[_selectItemIndex];

      await _audioPlayerManager.updateSongUrl(nextSong.audioURL);
      _audioPlayerManager.player.play();

      if (mounted) {
        setState(() => _song = nextSong);
      }
    } finally {
      if (mounted) {
        setState(() => _isChangingSong = false); // Mở khóa sau khi tải xong (dù thành công hay lỗi)
      }
    }
  }

  // Thêm async vào đầu hàm
  void _previousSong() async {
    if (widget.ListBaihat.isEmpty || _isChangingSong) return;

    if (mounted) {
      setState(() => _isChangingSong = true);
    }

    try {
      if (_isShuffle) {
        _selectItemIndex = Random().nextInt(widget.ListBaihat.length);
      } else {
        _selectItemIndex = (_selectItemIndex - 1 + widget.ListBaihat.length) % widget.ListBaihat.length;
      }

      final previousSong = widget.ListBaihat[_selectItemIndex];

      await _audioPlayerManager.updateSongUrl(previousSong.audioURL);
      _audioPlayerManager.player.play();

      if (mounted) {
        setState(() => _song = previousSong);
      }
    } finally {
      if (mounted) {
        setState(() => _isChangingSong = false);
      }
    }
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
