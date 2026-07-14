import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';
import '../models/models_music.dart';
import 'audio_player.dart';

class PlayPodcastScreen extends StatefulWidget {
  final PodCardModel podcast;

  const PlayPodcastScreen({super.key, required this.podcast});

  @override
  State<PlayPodcastScreen> createState() => _PlayPodcastScreenState();
}

class _PlayPodcastScreenState extends State<PlayPodcastScreen> {
  late AudioPlayerManager _audioPlayerManager;
  
  // Trạng thái cho các tính năng podcast
  double _currentSpeed = 1.0;
  Timer? _sleepTimer;
  int? _sleepMinutesLeft;

  @override
  void initState() {
    super.initState();
    _audioPlayerManager = AudioPlayerManager(songURL: widget.podcast.linkPodcardUrl);
    _audioPlayerManager.init();
    _audioPlayerManager.player.play();
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _audioPlayerManager.player.dispose();
    super.dispose();
  }

  // --- Các hàm tính năng Podcast ---

  // 1. Tua tới 15 giây
  void _seekForward() {
    final currentPosition = _audioPlayerManager.player.position;
    _audioPlayerManager.player.seek(currentPosition + const Duration(seconds: 15));
  }

  // 2. Tua lùi 15 giây
  void _seekBackward() {
    final currentPosition = _audioPlayerManager.player.position;
    final newPosition = currentPosition - const Duration(seconds: 15);
    _audioPlayerManager.player.seek(newPosition.isNegative ? Duration.zero : newPosition);
  }

  // 3. Đổi tốc độ phát
  void _toggleSpeed() {
    setState(() {
      if (_currentSpeed == 1.0) {
        _currentSpeed = 1.25;
      } else if (_currentSpeed == 1.25) {
        _currentSpeed = 1.5;
      } else if (_currentSpeed == 1.5) {
        _currentSpeed = 2.0;
      } else {
        _currentSpeed = 1.0;
      }
      _audioPlayerManager.player.setSpeed(_currentSpeed);
    });
  }

  // 4. Hẹn giờ ngủ (Hiển thị BottomSheet để chọn giờ)
  void _showSleepTimerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181818),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Hẹn giờ ngủ",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildTimerOption(context, 15),
              _buildTimerOption(context, 30),
              _buildTimerOption(context, 45),
              _buildTimerOption(context, 60),
              ListTile(
                title: const Center(child: Text("Tắt hẹn giờ", style: TextStyle(color: Colors.redAccent))),
                onTap: () {
                  _cancelSleepTimer();
                  Navigator.pop(context);
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerOption(BuildContext context, int minutes) {
    return ListTile(
      title: Center(child: Text("$minutes phút", style: const TextStyle(color: Colors.white))),
      onTap: () {
        _setSleepTimer(minutes);
        Navigator.pop(context);
      },
    );
  }

  void _setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    setState(() {
      _sleepMinutesLeft = minutes;
    });
    
    _sleepTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        if (_sleepMinutesLeft != null && _sleepMinutesLeft! > 1) {
          _sleepMinutesLeft = _sleepMinutesLeft! - 1;
        } else {
          // Hết giờ -> Tắt nhạc và hủy timer
          _audioPlayerManager.player.pause();
          _cancelSleepTimer();
        }
      });
    });
  }

  void _cancelSleepTimer() {
    _sleepTimer?.cancel();
    setState(() {
      _sleepTimer = null;
      _sleepMinutesLeft = null;
    });
  }

  // --- Giao diện ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7B1E9D), Color(0xFF121212)], // Màu nền cho podcast
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
                      "ĐANG PHÁT PODCAST",
                      style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Ảnh Podcast
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      widget.podcast.imagePodcardUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.podcasts, size: 100, color: Colors.white54),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Thông tin Podcast
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.podcast.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.podcast.author,
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              
              // Thanh tiến trình (Lấy từ file cũ)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                child: StreamBuilder<DurationState>(
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
                ),
              ),
              
              // Nút điều khiển (Tốc độ phát, Tua lui, Play/Pause, Tua tới, Giờ ngủ)
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0, left: 16.0, right: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Nút tốc độ phát
                    TextButton(
                      onPressed: _toggleSpeed,
                      child: Text(
                        "${_currentSpeed}x",
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    // Nút tua lùi 15s
                    IconButton(
                      onPressed: _seekBackward,
                      icon: const Icon(Icons.replay_10, color: Colors.white, size: 36), // Dùng tạm icon replay 10
                    ),
                    
                    // Nút Play/Pause (Lấy luồng từ file cũ)
                    StreamBuilder<PlayerState>(
                      stream: _audioPlayerManager.player.playerStateStream,
                      builder: (context, snapshot) {
                        final playState = snapshot.data;
                        final processingSate = playState?.processingState;
                        final playing = playState?.playing;

                        if (processingSate == ProcessingState.loading ||
                            processingSate == ProcessingState.buffering) {
                          return Container(
                            margin: const EdgeInsets.all(8),
                            width: 64,
                            height: 64,
                            child: const CircularProgressIndicator(),
                          );
                        } else if (playing != true) {
                          return IconButton(
                            iconSize: 64,
                            icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                            onPressed: _audioPlayerManager.player.play,
                          );
                        } else if (processingSate != ProcessingState.completed) {
                          return IconButton(
                            iconSize: 64,
                            icon: const Icon(Icons.pause_circle_filled, color: Colors.white),
                            onPressed: _audioPlayerManager.player.pause,
                          );
                        } else {
                          return IconButton(
                            iconSize: 64,
                            icon: const Icon(Icons.replay_circle_filled, color: Colors.white),
                            onPressed: () => _audioPlayerManager.player.seek(Duration.zero),
                          );
                        }
                      },
                    ),
                    
                    // Nút tua tới 15s
                    IconButton(
                      onPressed: _seekForward,
                      icon: const Icon(Icons.forward_10, color: Colors.white, size: 36),
                    ),
                    
                    // Nút cài giờ ngủ
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          onPressed: _showSleepTimerOptions,
                          icon: Icon(
                            Icons.bedtime,
                            color: _sleepMinutesLeft != null ? Colors.greenAccent : Colors.white54,
                            size: 28,
                          ),
                        ),
                        if (_sleepMinutesLeft != null)
                          Positioned(
                            bottom: 2,
                            child: Text(
                              "$_sleepMinutesLeft'",
                              style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}