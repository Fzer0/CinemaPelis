import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

class MovieProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Movie> _popularMovies = [];
  List<Movie> _searchResults = [];
  List<Movie> _favorites = [];
  bool _isLoading = false;
  int _currentPage = 1;
  String? _error;


  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get searchResults => _searchResults;
  List<Movie> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  MovieProvider() {
    loadFavorites();
  }

  Future<void> fetchPopularMovies({bool loadMore = false}) async {
    if (_isLoading || (!loadMore && _popularMovies.isNotEmpty)) return;

    _isLoading = true;
    notifyListeners();

    try {
      final movies = await _apiService.fetchPopularMovies(page: loadMore ? _currentPage + 1 : 1);
      if (loadMore) {
        _popularMovies.addAll(movies);
        _currentPage++;
      } else {
        _popularMovies = movies;
        _currentPage = 1;
      }
      _error = null;

    } catch (e) {
      _error = 'Failed to load popular movies: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchMovies(query);
    } catch (e) {
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Movie> fetchMovieDetails(int movieId) async {
    try {
      return await _apiService.fetchMovieDetails(movieId);
    } catch (e) {
      throw Exception('Failed to load movie details');
    }
  }

  void toggleFavorite(Movie movie) {
    if (_favorites.any((fav) => fav.id == movie.id)) {
      _favorites.removeWhere((fav) => fav.id == movie.id);
    } else {
      _favorites.add(movie);
    }
    saveFavorites();
    notifyListeners();
  }

  bool isFavorite(Movie movie) {
    return _favorites.any((fav) => fav.id == movie.id);
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList('favorites') ?? [];
    _favorites = favoritesJson.map((json) => Movie.fromJson(jsonDecode(json))).toList();
    notifyListeners();
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = _favorites.map((movie) => jsonEncode(movie.toJson())).toList();
    await prefs.setStringList('favorites', favoritesJson);
  }
}
