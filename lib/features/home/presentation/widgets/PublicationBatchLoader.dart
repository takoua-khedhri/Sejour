import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parent_5sur5/features/home/domain/entities/publication.dart';
import 'package:parent_5sur5/features/home/presentation/widgets/publication_item.dart';

class PublicationBatchLoader extends StatefulWidget {
  final List<Publication> publications;
  final String token;
  final int batchSize;
  final ScrollController? scrollController;

  const PublicationBatchLoader({
    Key? key,
    required this.publications,
    required this.token,
    this.batchSize = 5,
    this.scrollController,
  }) : super(key: key);

  @override
  _PublicationBatchLoaderState createState() => _PublicationBatchLoaderState();
}

class _PublicationBatchLoaderState extends State<PublicationBatchLoader> {
  late List<Publication> _visiblePublications;
  late ScrollController _scrollController;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _visiblePublications = widget.publications.take(widget.batchSize).toList();
    _hasMore = widget.publications.length > _visiblePublications.length;
    _scrollController.addListener(_scrollListener);
    print('Initial load: ${_visiblePublications.length} publications');
  }

  @override
  void didUpdateWidget(PublicationBatchLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.publications != widget.publications) {
      setState(() {
        _visiblePublications = widget.publications.take(widget.batchSize).toList();
        _hasMore = widget.publications.length > _visiblePublications.length;
        print('Publications updated: ${_visiblePublications.length} loaded');
      });
    }
  }

  void _scrollListener() {
    if (!_scrollController.hasClients || _isLoading || !_hasMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    const scrollThreshold = 100;

    if (maxScroll - currentScroll <= scrollThreshold) {
      print('Scroll near end: loading more publications');
      _loadMorePublications();
    }
  }

  Future<void> _loadMorePublications() async {
    if (_isLoading || !_hasMore) {
      print('No more publications to load or already loading');
      return;
    }

    setState(() {
      _isLoading = true;
    });
    print('Loading more publications...');

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    
    final nextBatch = widget.publications
        .skip(_visiblePublications.length)
        .take(widget.batchSize)
        .toList();

    setState(() {
      _visiblePublications.addAll(nextBatch);
      _isLoading = false;
      _hasMore = _visiblePublications.length < widget.publications.length;
      print('Loaded ${nextBatch.length} more publications. Total: ${_visiblePublications.length}');
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
      ),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _visiblePublications.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _visiblePublications.length) {
            return PublicationItem(
              publication: _visiblePublications[index],
              token: widget.token,
              shouldLoadMedia: index < 10,
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: _isLoading 
                    ? const CircularProgressIndicator()
                    : const SizedBox.shrink(),
              ),
            );
          }
        },
      ),
    );
  }
}