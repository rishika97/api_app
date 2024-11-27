// ignore_for_file: use_build_context_synchronously

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
  bool _isLoading = false;

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
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10); // Limit to 10 items
      }
      prefs.setStringList('movieSearches', _recentSearches);
    }
  }

  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search movies...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                  ),
                  onSubmitted: _searchMovies,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _searchMovies(_searchController.text),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 15),
                ),
                child: const Icon(Icons.search),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            const Text(
              'Recent Searches:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _recentSearches.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final search = _recentSearches[index];
                  return ElevatedButton(
                    onPressed: () => _searchMovies(search),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(search),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
          ],

          // Movie Results or Loading
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : _movies.isEmpty
                ? const Center(
              child: Text(
                'No movies found. Start searching!',
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: _movies.length,
              itemBuilder: (context, index) {
                final movie = _movies[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: movie['poster_path'] != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w92${movie['poster_path']}',
                        width: 50,
                      ),
                    )
                        : const Icon(Icons.movie, size: 50),
                    title: Text(
                      movie['title'] ?? 'No Title',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      movie['overview'] ?? 'No description available',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
