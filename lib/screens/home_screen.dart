import 'package:flutter/material.dart';
import 'package:api_app/screens/dog_ceo_screen.dart';
import 'package:api_app/screens/json_place_holder_screen.dart';
import 'package:api_app/screens/movie_screen.dart';
import 'package:api_app/screens/weather_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _tabs = [
    {
      'icon': Icons.movie,
      'label': 'Movies',
      'screen': const MovieScreen(),
    },
    {
      'icon': Icons.cloud,
      'label': 'Weather',
      'screen': const WeatherScreen(),
    },
    {
      'icon': Icons.api,
      'label': 'Json',
      'screen': const JsonPlaceHolderScreen(),
    },
    {
      'icon': Icons.pets,
      'label': 'Dogs',
      'screen': const DogScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search Hub'),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            tabs: _tabs.map((tab) {
              final int index = _tabs.indexOf(tab);
              return Tab(
                icon: Column(
                  children: [
                    Icon(tab['icon']),
                    AnimatedOpacity(
                      opacity: _selectedIndex == index ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(tab['label'], style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: _tabs.map((tab) => tab['screen'] as Widget).toList(),
        ),
      ),
    );
  }
}
