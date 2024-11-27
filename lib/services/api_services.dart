import 'dart:convert';
import 'package:api_app/models/post_model.dart';
import 'package:api_app/models/todo_model.dart';
import 'package:api_app/models/user_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  final String tmdbApiKey = '8f1d3cfee209faf7c606c9acf86a6757';
  final String jsonPlaceholderBaseUrl = 'https://jsonplaceholder.typicode.com';
  final String dogCeoBaseUrl = 'https://dog.ceo/api';

  final String weatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
  final String weatherApiKey = '678d195f30f289c84fbf01e86a21cdd1';

  // TMDB: Fetch movies by query
  Future<List<dynamic>> searchMovies(String query) async {
    final response = await http.get(
      Uri.parse('$tmdbBaseUrl/search/movie?api_key=$tmdbApiKey&query=$query'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'] ?? [];
    } else {
      throw Exception('Failed to load movies');
    }
  }

  // OpenWeather: Fetch weather by city name
  Future<Map<String, dynamic>> fetchWeather(String city) async {
    final response = await http.get(
      Uri.parse('$weatherBaseUrl/weather?q=$city&appid=$weatherApiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  // JSONPlaceholder: Fetch users
  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('$jsonPlaceholderBaseUrl/users'));

    if (response.statusCode == 200) {
      final List<dynamic> userJson = jsonDecode(response.body);
      return userJson.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  // JSONPlaceholder: Fetch posts
  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse('$jsonPlaceholderBaseUrl/posts'));

    if (response.statusCode == 200) {
      final List<dynamic> postJson = jsonDecode(response.body);
      return postJson.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  // JSONPlaceholder: Fetch Todos
  Future<List<Todo>> fetchTodos() async {
    final response = await http.get(Uri.parse('$jsonPlaceholderBaseUrl/todos'));

    if (response.statusCode == 200) {
      final List<dynamic> todoJson = jsonDecode(response.body);
      return todoJson.map((json) => Todo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  // Dog CEO: Fetch dog breeds
  Future<List<String>> fetchDogBreeds() async {
    final response = await http.get(Uri.parse('$dogCeoBaseUrl/breeds/list/all'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['message'] as Map<String, dynamic>).keys.toList();
    } else {
      throw Exception('Failed to load dog breeds');
    }
  }

  // Dog CEO: Fetch images for a breed
  Future<List<String>> fetchDogImages(String breed) async {
    final response = await http.get(Uri.parse('$dogCeoBaseUrl/breed/$breed/images'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['message']);
    } else {
      throw Exception('Failed to load images for breed $breed');
    }
  }

}
