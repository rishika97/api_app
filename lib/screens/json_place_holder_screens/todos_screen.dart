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
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No todos found.',
              style: TextStyle(fontSize: 16),
            ),
          );
        } else {
          final todos = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        todo.completed ? Icons.check_circle : Icons.cancel,
                        color: todo.completed ? Colors.green : Colors.red,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              todo.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              todo.completed
                                  ? 'Status: Completed'
                                  : 'Status: Pending',
                              style: TextStyle(
                                fontSize: 14,
                                color: todo.completed
                                    ? Colors.green[700]
                                    : Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
