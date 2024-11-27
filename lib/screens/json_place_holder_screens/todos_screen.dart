import 'package:api_app/models/todo_model.dart';
import 'package:flutter/material.dart';

class TodoScreen extends StatelessWidget {
  final Future<List<Todo>> futureTodos;
  const TodoScreen({super.key, required this.futureTodos});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Todo>>(
      future: futureTodos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No todos found.'));
        } else {
          final todos = snapshot.data!;
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return ListTile(
                title: Text(todo.title),
                trailing: Icon(
                  todo.completed ? Icons.check : Icons.close,
                  color: todo.completed ? Colors.green : Colors.red,
                ),
              );
            },
          );
        }
      },
    );
  }
}
