import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parent_5sur5/features/home/domain/entities/publication.dart';
import 'package:parent_5sur5/features/favorites/presentation/blocs/favorites_bloc.dart';
import 'package:parent_5sur5/features/favorites/presentation/blocs/favorites_event.dart';
import 'package:parent_5sur5/features/favorites/presentation/blocs/favorites_state.dart';

class FavoritesScreen extends StatefulWidget {
  final String codeSejour;
  final String token;

  const FavoritesScreen({
    Key? key,
    required this.codeSejour,
    required this.token,
  }) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _loadFavorites();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void _loadFavorites() {
    debugPrint('Chargement des favoris...');
    context.read<FavoritesBloc>().add(
      LoadFavorites(widget.codeSejour, widget.token),
    );
  }

  void _toggleLike(Publication publication) {
    context.read<FavoritesBloc>().add(
      ToggleFavorite(
        publication.id,
        !publication.isLiked,
        widget.token,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<FavoritesBloc, FavoritesState>(
        listener: (context, state) {
          if (state is FavoritesError && _isMounted) {
            _showErrorSnackbar(state.message);
          }
        },
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FavoritesLoaded) {
            if (state.favorites.isEmpty) {
              return const Center(child: Text('Aucun favori trouvé'));
            }

            return ListView.builder(
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final publication = state.favorites[index];
                return _PublicationItem(
                  publication: publication,
                  onLikePressed: () => _toggleLike(publication),
                );
              },
            );
          }

          if (state is FavoritesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadFavorites,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Chargement...'));
        },
      ),
    );
  }
}

class _PublicationItem extends StatelessWidget {
  final Publication publication;
  final VoidCallback onLikePressed;

  const _PublicationItem({
    required this.publication,
    required this.onLikePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (publication.type == 'video' && publication.thumbnailUrl != null)
            Image.network(
              publication.thumbnailUrl!,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Erreur de chargement thumbnail: $error');
                return Container(
                  height: 200,
                  color: Colors.grey,
                  child: const Icon(Icons.error),
                );
              },
            )
          else if (publication.type == 'image')
            Image.network(
              publication.url,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Erreur de chargement image: $error');
                return Container(
                  height: 200,
                  color: Colors.grey,
                  child: const Icon(Icons.error),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  
                      if (publication.comment != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(publication.comment!),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    publication.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: publication.isLiked ? Colors.red : null,
                  ),
                  onPressed: onLikePressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}