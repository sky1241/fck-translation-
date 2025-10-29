import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget pour jouer un message vocal
class AudioPlayerWidget extends ConsumerStatefulWidget {
  final String audioUrl;
  final bool isMe;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    required this.isMe,
  });

  @override
  ConsumerState<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends ConsumerState<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = true;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _error;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _audioPlayer.setFilePath(widget.audioUrl);
      _duration = _audioPlayer.duration ?? Duration.zero;
      _isLoading = false;
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }

    // Écouter les changements d'état
    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
        if (state.processingState == ProcessingState.completed) {
          _position = Duration.zero;
        }
      });
    });

    // Écouter la position
    _audioPlayer.positionStream.listen((position) {
      setState(() => _position = position);
    });
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isMe 
            ? (colorScheme.secondary.withValues(alpha: 0.1))
            : (colorScheme.primary.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton Play/Pause
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: widget.isMe ? colorScheme.secondary : colorScheme.primary,
                  ),
            onPressed: _error == null ? _togglePlayPause : null,
            iconSize: 28,
          ),
          
          // Barre de progression
          Expanded(
            child: _error != null
                ? Text(
                    '❌ Error',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.error,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Barre de progression
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        ),
                        child: Slider(
                          value: _duration.inMilliseconds > 0
                              ? _position.inMilliseconds.toDouble()
                              : 0.0,
                          max: _duration.inMilliseconds.toDouble(),
                          onChanged: (value) async {
                            await _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                          },
                        activeColor: widget.isMe ? colorScheme.secondary : colorScheme.primary,
                        inactiveColor: widget.isMe 
                            ? colorScheme.secondary.withValues(alpha: 0.3)
                            : colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      // Durée
                      Text(
                        '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

