import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../models/movie.dart';
import 'movie_detail_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().fetchPopularMovies();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      context.read<MovieProvider>().fetchPopularMovies(loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cinema'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          if (movieProvider.isLoading && movieProvider.popularMovies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (movieProvider.error != null && movieProvider.popularMovies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${movieProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => movieProvider.fetchPopularMovies(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (movieProvider.popularMovies.isEmpty && !movieProvider.isLoading) {
            return const Center(
              child: Text('No movies available'),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: movieProvider.popularMovies.length + (movieProvider.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == movieProvider.popularMovies.length) {
                return const Center(child: CircularProgressIndicator());
              }

              final movie = movieProvider.popularMovies[index];
              return MovieListItem(movie: movie);
            },
          );
        },
      ),
    );
  }
}

class MovieListItem extends StatelessWidget {
  final Movie movie;

  const MovieListItem({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
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
  }
}
