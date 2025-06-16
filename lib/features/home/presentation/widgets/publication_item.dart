import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parent_5sur5/features/home/presentation/blocs/home_bloc.dart';
import 'package:parent_5sur5/features/home/presentation/blocs/home_event.dart';
import 'package:parent_5sur5/features/home/presentation/blocs/home_state.dart';
import 'package:parent_5sur5/features/home/domain/entities/publication.dart';
import 'package:parent_5sur5/features/favorites/presentation/blocs/favorites_bloc.dart';
import 'package:parent_5sur5/features/favorites/presentation/blocs/favorites_event.dart';

class PublicationItem extends StatefulWidget {
  final Publication publication;
  final String token;
  final bool shouldLoadMedia;

  const PublicationItem({
    required this.publication,
    required this.token,
    this.shouldLoadMedia = false,
    Key? key,
  }) : super(key: key);

  @override
  State<PublicationItem> createState() => _PublicationItemState();
}

class _PublicationItemState extends State<PublicationItem> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isDisposed = false;
  bool _videoError = false;
  bool _isInitializing = false;
  int _retryCount = 0;
  bool _shouldInitializeVideo = false;
  bool _isVideoStarted = false;
  final double _mediaHeight = 300.0; 

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initVideoWithRetry() async {
    if (_isDisposed || _isInitializing || !_shouldInitializeVideo) return;

    setState(() {
      _isInitializing = true;
      _videoError = false;
    });

    try {
      _videoController?.dispose();
      _chewieController?.dispose();

      _videoController = VideoPlayerController.network(
        widget.publication.url,
        httpHeaders: {'Authorization': 'Bearer ${widget.token}'},
      );

      await _videoController!.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Video initialization timeout');
        },
      );

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      if (!_isDisposed && mounted) {
        setState(() {
          _videoError = false;
          _isInitializing = false;
          _retryCount = 0;
        });
      }
    } catch (e) {
      debugPrint('Video initialization error: $e');
      if (!_isDisposed && mounted) {
        _handleVideoError();
      }
    }
  }

  void _handleVideoError() {
    if (_isDisposed || !mounted) return;

    setState(() {
      _videoError = true;
      _isInitializing = false;
    });

    if (_retryCount < 3) {
      _retryCount++;
      Future.delayed(const Duration(seconds: 2), () {
        if (!_isDisposed && mounted && _shouldInitializeVideo) {
          _initVideoWithRetry();
        }
      });
    }
  }

  @override
  void didUpdateWidget(PublicationItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.publication.url != widget.publication.url) {
      _shouldInitializeVideo = false;
      _isVideoStarted = false;
      _videoController?.dispose();
      _chewieController?.dispose();
      _videoController = null;
      _chewieController = null;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _shouldInitializeVideo = false;
    _videoController?.pause();
    _videoController?.dispose();
    _chewieController?.dispose();
    _videoController = null;
    _chewieController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.publication.type == 'image')
            _buildImageContent()
          else if (widget.publication.type == 'video')
            _buildVideoContent(),
          _buildFooter(),
        ],
      ),
    );
  }
Widget _buildImageContent() {
  if (!widget.shouldLoadMedia) {
    return SizedBox(
      height: _mediaHeight,
      child: Container(
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image, size: 50, color: Colors.grey),
            const SizedBox(height: 8),
            const Text('Image en attente de chargement',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  return SizedBox(
    height: _mediaHeight,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: widget.publication.url,
        httpHeaders: {'Authorization': 'Bearer ${widget.token}'},
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (_, __) => _buildPlaceholder(),
        errorWidget: (_, __, ___) => _buildErrorWidget(),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
        memCacheWidth: MediaQuery.of(context).size.width.toInt(),
        memCacheHeight: _mediaHeight.toInt(),
        filterQuality: FilterQuality.medium,
      ),
    ),
  );
}

Widget _buildVideoContent() {
  if (!_isVideoStarted) {
    return SizedBox(
      height: _mediaHeight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isVideoStarted = true;
                _shouldInitializeVideo = true;
              });
              _initVideoWithRetry();
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Lire la vidéo'),
          ),
        ),
      ),
    );
  }

  if (_videoError) {
    return SizedBox(
      height: _mediaHeight,
      child: _buildVideoErrorWidget(),
    );
  }

  if (_chewieController == null ||
      !_chewieController!.videoPlayerController.value.isInitialized) {
    return SizedBox(
      height: _mediaHeight,
      child: _buildPlaceholder(),
    );
  }

  // Nouvelle solution pour gérer le débordement
  return LayoutBuilder(
    builder: (context, constraints) {
      final videoRatio = _chewieController!.videoPlayerController.value.aspectRatio;
      final containerWidth = constraints.maxWidth;
      final calculatedHeight = containerWidth / videoRatio;

      return SizedBox(
        width: containerWidth,
        height: calculatedHeight > _mediaHeight ? _mediaHeight : calculatedHeight,
        child: AspectRatio(
          aspectRatio: videoRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Chewie(
              controller: _chewieController!,
            ),
          ),
        ),
      );
    },
  );
}
  Widget _buildPlaceholder() {
    return Container(
      height: _mediaHeight,
      color: Colors.grey[200],
      child: const Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildVideoErrorWidget() {
    return Container(
      height: _mediaHeight,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam_off, size: 50),
          const SizedBox(height: 16),
          const Text('Impossible de charger la vidéo'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _retryCount = 0;
                _videoError = false;
                _isVideoStarted = true;
                _shouldInitializeVideo = true;
              });
              _initVideoWithRetry();
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: _mediaHeight,
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.broken_image, size: 50)),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.publication.comment?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                widget.publication.comment!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          Row(
            children: [
              BlocListener<HomeBloc, HomeState>(
                listener: (context, state) {
                  if (state is PublicationLikeUpdated &&
                      state.publicationId == widget.publication.id) {
                        //updating like
                  }
                },
                child: IconButton(
                  icon: Icon(
                    widget.publication.isLiked 
                        ? Icons.favorite 
                        : Icons.favorite_border,
                    color: widget.publication.isLiked ? Colors.red : null,
                  ),
                  onPressed: () {
                    final newLikeState = !widget.publication.isLiked;
                    
                    context.read<HomeBloc>().add(
                      TogglePublicationLikeEvent(
                        publicationId: widget.publication.id,
                        isLiked: newLikeState,
                        token: widget.token,
                      ),
                    );
                    
                    if (newLikeState) {
                      context.read<FavoritesBloc>().add(
                        ToggleFavorite(
                          widget.publication.id,
                          newLikeState,
                          widget.token,
                        ),
                      );
                    }
                  },
                ),
              ),
              Text('${widget.publication.isLiked ? 1 : 0} j\'aime'),
            ],
          ),
        ],
      ),
    );
  }
}