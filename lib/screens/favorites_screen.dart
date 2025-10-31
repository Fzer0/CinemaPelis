import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';

import 'movie_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          final favorites = movieProvider.favorites;

          if (favorites.isEmpty) {
            return const Center(
              child: Text('No favorite movies yet'),
            );
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final movie = favorites[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: movie.posterPath.isNotEmpty
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w92${movie.posterPath}',
                          width: 50,
                          height: 75,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie),
                        )
                      : const Icon(Icons.movie, size: 50),
                  title: Text(movie.title),
                  subtitle: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(movie.voteAverage.toStringAsFixed(1)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => movieProvider.toggleFavorite(movie),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailScreen(movieId: movie.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
