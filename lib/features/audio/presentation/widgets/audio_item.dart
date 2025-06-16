import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:parent_5sur5/features/home/presentation/blocs/home_bloc.dart';
import 'package:parent_5sur5/features/home/presentation/blocs/home_event.dart';
import '../../domain/entities/audio.dart';

class AudioItem extends StatefulWidget {
  final Audio audio;
  final String token;

  const AudioItem({
    required this.audio,
    required this.token,
    Key? key,
  }) : super(key: key);

  @override
  State<AudioItem> createState() => _AudioItemState();
}

class _AudioItemState extends State<AudioItem> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioPlaying = false;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      // Écoute des changements d'état
      _audioPlayer.playerStateStream.listen((playerState) {
        if (mounted) {
          setState(() {
            _isAudioPlaying = playerState.playing;
            if (playerState.processingState == ProcessingState.loading) {
              _isLoading = true;
            } else {
              _isLoading = false;
            }
          });
        }
      });

      // Écoute de la position
      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _audioPosition = position;
          });
        }
      });

      // Écoute de la durée
      _audioPlayer.durationStream.listen((duration) {
        if (mounted) {
          setState(() {
            _audioDuration = duration ?? Duration.zero;
          });
        }
      });

      _audioPlayer.playbackEventStream.listen((event) {},
          onError: (Object e, StackTrace st) {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
        debugPrint('Erreur de lecture: $e');
      });
    } catch (e) {
      debugPrint('Erreur initialisation player: $e');
    }
  }

_toggleAudioPlayback() async {
  try {
    if (_isAudioPlaying) {
      await _audioPlayer.pause();
    } else {
      // Reset le player avant de jouer
      await _audioPlayer.stop();
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(widget.audio.url),
          headers: {
            'Authorization': 'Bearer ${widget.token}',
            'Accept': 'audio/*',
          },
        ),
        preload: true, // Préchargement
      );
      
      // Démarrer la lecture
      await _audioPlayer.play();
      
      // Reset l'état d'erreur
      if (mounted) {
        setState(() {
          _hasError = false;
        });
      }
    }
  } catch (e, stackTrace) {
    debugPrint('Erreur audio: $e\n$stackTrace');
    if (mounted) {
      setState(() {
        _hasError = true;
      });
    }
    
    // Message d'erreur précis
    String errorMessage = 'Erreur de lecture';
    if (e.toString().contains('Certificate')) {
      errorMessage = 'Problème de certificat SSL';
    } else if (e.toString().contains('404')) {
      errorMessage = 'Fichier audio introuvable';
    } else if (e.toString().contains('403')) {
      errorMessage = 'Accès non autorisé';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAudioContent(),
          _buildAudioFooter(context),
        ],
      ),
    );
  }

  Widget _buildAudioContent() {
    final maxDuration = _audioDuration.inMilliseconds;
    final currentPosition = _audioPosition.inMilliseconds;
    final safePosition = currentPosition.clamp(0, maxDuration).toDouble();
    final safeMaxDuration = maxDuration > 0 ? maxDuration.toDouble() : 1.0;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Remplacement de la partie thumbnail par une icône musicale
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.music_note, size: 30),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: _isLoading
                              ? const CircularProgressIndicator()
                              : Icon(
                                  _isAudioPlaying 
                                      ? Icons.pause_circle 
                                      : Icons.play_circle,
                                  size: 36,
                                  color: _hasError
                                      ? Colors.red
                                      : Theme.of(context).primaryColor,
                                ),
                          onPressed: _hasError ? null : _toggleAudioPlayback,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.audio.comment?.isNotEmpty ?? false)
                                Text(
                                  widget.audio.comment!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              Text(
                                _formatDate(widget.audio.date),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                      child: Column(
                        children: [
                          Slider(
                            value: safePosition,
                            min: 0.0,
                            max: safeMaxDuration,
                            onChanged: _hasError
                                ? null
                                : (value) {
                                    setState(() {
                                      _audioPosition = 
                                          Duration(milliseconds: value.toInt());
                                    });
                                  },
                            onChangeEnd: _hasError
                                ? null
                                : (value) {
                                    _audioPlayer.seek(
                                        Duration(milliseconds: value.toInt()));
                                  },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_audioPosition),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _hasError ? Colors.red : null,
                                ),
                              ),
                              Text(
                                _formatDuration(_audioDuration),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _hasError ? Colors.red : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_hasError)
            Text(
              'Erreur de lecture',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _formatDate(String dateString) {
  try {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  } catch (e) {
    return dateString;
  }
}
}