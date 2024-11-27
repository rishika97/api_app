import 'package:api_app/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MovieScreen extends StatefulWidget {
  const MovieScreen({super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _movies = [];
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('movieSearches') ?? [];
    });
  }

  Future<void> _saveSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_recentSearches.contains(query)) {
      _recentSearches.add(query);
      prefs.setStringList('movieSearches', _recentSearches);
    }
  }

  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) return;

    try {
      final results = await apiService.searchMovies(query);
      setState(() {
        _movies = results;
      });
      await _saveSearch(query);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search movies...',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _searchMovies(_searchController.text),
              ),
            ),
            onSubmitted: _searchMovies,
          ),
          const SizedBox(height: 10),
          if (_recentSearches.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _recentSearches.map((search) {
                  return GestureDetector(
                    onTap: () => _searchMovies(search),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Chip(label: Text(search)),
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 20),
          Expanded(
            child: _movies.isEmpty
                ? const Center(child: Text('No movies found'))
                : ListView.builder(
              itemCount: _movies.length,
              itemBuilder: (context, index) {
                final movie = _movies[index];
                return Card(
                  child: ListTile(
                    leading: movie['poster_path'] != null
                        ? Image.network(
                      'https://image.tmdb.org/t/p/w92${movie['poster_path']}',
                      width: 50,
                    )
                        : const Icon(Icons.movie, size: 50),
                    title: Text(movie['title']),
                    subtitle: Text(movie['overview'] ?? 'No description'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
