import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../models/movie.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Movie? _movie;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }

  Future<void> _loadMovieDetails() async {
    try {
      final movie = await context.read<MovieProvider>().fetchMovieDetails(widget.movieId);
      if (mounted) {
        setState(() {
          _movie = movie;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load movie details')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_movie?.title ?? 'Movie Details'),
        actions: [
          if (_movie != null)
            Consumer<MovieProvider>(
              builder: (context, movieProvider, child) {
                final isFav = movieProvider.isFavorite(_movie!);
                return IconButton(
                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                  onPressed: () => movieProvider.toggleFavorite(_movie!),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _movie == null
              ? const Center(child: Text('Failed to load movie details'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Backdrop image
                      if (_movie!.backdropPath.isNotEmpty)
                        Image.network(
                          'https://image.tmdb.org/t/p/w500${_movie!.backdropPath}',
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 250,
                            color: Colors.grey,
                            child: const Icon(Icons.movie, size: 100),
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              _movie!.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),

                            // Release year and rating
                            Row(
                              children: [
                                Text(
                                  _movie!.releaseDate.isNotEmpty
                                      ? _movie!.releaseDate.substring(0, 4)
                                      : 'N/A',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                                Text(
                                  _movie!.voteAverage.toStringAsFixed(1),
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Genres
                            if (_movie!.genres.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                children: _movie!.genres
                                    .map((genre) => Chip(label: Text(genre)))
                                    .toList(),
                              ),
                            const SizedBox(height: 16),

                            // Overview
                            Text(
                              'Overview',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(_movie!.overview),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
