import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';  

// Modelo Todo
class Todo {
  String description;
  bool isCompleted;

  Todo({
    required this.description,
    this.isCompleted = false,
  });
}

// Notificador TodoNotifier
class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier() : super([]);

  void addTodo(String description) {
    state = [...state, Todo(description: description)];
  }

  void toggleTodoStatus(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          Todo(
            description: state[i].description,
            isCompleted: !state[i].isCompleted,
          )
        else
          state[i],
    ];
  }

  void removeTodoAt(int index) {
    state = [...state]..removeAt(index);
  }
}

// Proveedor de la lista de Todo
final todoListProvider =
    StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App - Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoScreen(),
    );
  }
}

// Pantalla TodoScreen
class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});  // Asegúrate de pasar el key correctamente

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Todo App con Riverpod')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Agregar Tarea',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  ref.read(todoListProvider.notifier).addTodo(value);
                  controller.clear();
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  leading: Checkbox(
                    value: todo.isCompleted,
                    onChanged: (value) {
                      ref
                          .read(todoListProvider.notifier)
                          .toggleTodoStatus(index);
                    },
                  ),
                  title: InkWell(
                    onTap: () {
                      ref
                          .read(todoListProvider.notifier)
                          .toggleTodoStatus(index);
                    },
                    child: Text(
                      todo.description,
                      style: TextStyle(
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      ref
                          .read(todoListProvider.notifier)
                          .removeTodoAt(index);
                    },
                    icon: const Icon(Icons.delete),
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
