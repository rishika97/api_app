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
      _recentSearches.add(city);
      prefs.setStringList('weatherSearches', _recentSearches);
    }
  }

  Future<void> _searchWeather(String city) async {
    if (city.isEmpty) return;

    try {
      final data = await apiService.fetchWeather(city);
      setState(() {
        _weatherData = data;
      });
      await _saveSearch(city);
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
              hintText: 'Enter city name...',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _searchWeather(_searchController.text),
              ),
            ),
            onSubmitted: _searchWeather,
          ),
          const SizedBox(height: 10),
          if (_recentSearches.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _recentSearches.map((search) {
                  return GestureDetector(
                    onTap: () => _searchWeather(search),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Chip(label: Text(search)),
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 20),
          if (_weatherData != null)
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _weatherData!['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Temperature: ${_weatherData!['main']['temp']}°C',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Weather: ${_weatherData!['weather'][0]['description']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Humidity: ${_weatherData!['main']['humidity']}%',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
