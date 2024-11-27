import 'package:flutter/material.dart';
import 'package:api_app/models/post_model.dart';
import 'package:api_app/models/todo_model.dart';
import 'package:api_app/models/user_model.dart';
import 'package:api_app/screens/json_place_holder_screens/posts_screen.dart';
import 'package:api_app/screens/json_place_holder_screens/todos_screen.dart';
import 'package:api_app/screens/json_place_holder_screens/users_screen.dart';
import 'package:api_app/services/api_services.dart';

class JsonPlaceHolderScreen extends StatefulWidget {
  const JsonPlaceHolderScreen({super.key});

  @override
  JsonPlaceHolderScreenState createState() => JsonPlaceHolderScreenState();
}

class JsonPlaceHolderScreenState extends State<JsonPlaceHolderScreen> {
  late Future<List<User>> futureUsers;
  late Future<List<Post>> futurePosts;
  late Future<List<Todo>> futureTodos;
  String selectedScreen = 'Users';  // Default screen is 'Users'

  @override
  void initState() {
    super.initState();
    // Fetch the data for all screens upfront
    futureUsers = ApiService().fetchUsers();
    futurePosts = ApiService().fetchPosts();
    futureTodos = ApiService().fetchTodos();
  }

  // Function to display content based on the selected screen
  Widget getSelectedScreen() {
    switch (selectedScreen) {
      case 'Posts':
        return PostScreen(futurePosts: futurePosts);
      case 'Todos':
        return TodoScreen(futureTodos: futureTodos);
      default:
        return UserScreen(futureUsers: futureUsers);
    }
  }

  Widget getSelectedScreenTitle() {
    switch (selectedScreen) {
      case 'Posts':
        return const Text('Posts');
      case 'Todos':
        return const Text('Todos');
      default:
        return const Text('Users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: getSelectedScreenTitle(),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              setState(() {
                selectedScreen = result;
              });
            },
            itemBuilder: (BuildContext context) {
              return ['Users', 'Posts', 'Todos'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: getSelectedScreen(),
    );
  }
}
