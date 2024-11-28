// ignore_for_file: use_build_context_synchronously

import 'package:api_app/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _weatherData;
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
      _recentSearches = prefs.getStringList('weatherSearches') ?? [];
    });
  }

  Future<void> _saveSearch(String city) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_recentSearches.contains(city)) {
      _recentSearches.insert(0, city);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10); // Limit to 10 items
      }
      prefs.setStringList('weatherSearches', _recentSearches);
    }
  }

  Future<void> _searchWeather(String city) async {
    if (city.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = await apiService.fetchWeather(city);
      setState(() {
        _weatherData = data;
      });
      await _saveSearch(city);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An issue has been detected. Please retry.')),
      );
      debugPrint('Error: $error');
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
                    hintText: 'Enter city name...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                  ),
                  onSubmitted: _searchWeather,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _searchWeather(_searchController.text),
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
                    onPressed: () => _searchWeather(search),
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

          // Weather Data or Loading Indicator
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : _weatherData == null
                ? const Center(
              child: Text(
                'Search for weather updates!',
                style: TextStyle(fontSize: 16),
              ),
            )
                : SingleChildScrollView(
                  child: Card(
                                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _weatherData!['name'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            Icons.wb_sunny,
                            color: Colors.orange,
                            size: 32,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const Icon(
                            Icons.thermostat,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Temperature: ${_weatherData!['main']['temp']}°C',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.water_drop,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Humidity: ${_weatherData!['main']['humidity']}%',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.cloud,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Weather: ${_weatherData!['weather'][0]['description']}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                                ),
                              ),
                ),
          ),
        ],
      ),
    );
  }
}
