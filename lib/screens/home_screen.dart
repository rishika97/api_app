import 'package:api_app/screens/dog_ceo_screen.dart';
import 'package:api_app/screens/json_place_holder_screen.dart';
import 'package:api_app/screens/movie_screen.dart';
import 'package:api_app/screens/weather_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search Hub'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.movie), text: 'Movies'),
              Tab(icon: Icon(Icons.cloud), text: 'Weather'),
              Tab(icon: Icon(Icons.api), text: 'Json'),
              Tab(icon: Icon(Icons.pets), text: 'Dogs'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MovieScreen(),
            WeatherScreen(),
            JsonPlaceHolderScreen(),
            DogScreen(),
          ],
        ),
      ),
    );
  }
}
