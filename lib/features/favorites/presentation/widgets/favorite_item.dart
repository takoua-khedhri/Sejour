import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:parent_5sur5/features/home/domain/entities/publication.dart';

class FavoriteItem extends StatelessWidget {
  final Publication publication;
  final Function(bool) onLike;

  const FavoriteItem({
    Key? key,
    required this.publication,
    required this.onLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        publication.type == 'image'
            ? CachedNetworkImage(imageUrl: publication.url)
            : _VideoPlayerWidget(url: publication.url), // Correction du nom
        IconButton(
          icon: Icon(
            publication.isLiked ? Icons.favorite : Icons.favorite_border,
            color: Colors.red,
          ),
          onPressed: () => onLike(!publication.isLiked),
        ),
      ],
    );
  }
}

// Ajout du widget manquant (sans modifier la fonctionnalité existante)
class _VideoPlayerWidget extends StatefulWidget {
  final String url;

  const _VideoPlayerWidget({required this.url});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}