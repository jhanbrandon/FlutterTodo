import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'detalles_tarea.dart';
import 'todo_storage.dart';


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
  TodoNotifier() : super([]) {
    _loadTodos();  // Cargar tareas al inicializar el notificador
  }

  Future<void> _loadTodos() async {
    state = await TodoStorage.loadTodos();  // Cargar tareas desde shared_preferences
  }

  Future<void> _saveTodos() async {
    await TodoStorage.saveTodos(state);  // Guardar tareas en shared_preferences
  }

  void addTodo(String description) {
    state = [...state, Todo(description: description)];
    _saveTodos();  // Guardar cambios
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
    _saveTodos();  // Guardar cambios
  }

  void removeTodoAt(int index) {
    state = [...state]..removeAt(index);
    _saveTodos();  // Guardar cambios
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
        primarySwatch: Colors.blue
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PantallaDeDetalles(todo: todo),
                        ),
                      );
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar Eliminación"),
          content: const Text("¿Estás seguro de que deseas eliminar esta tarea?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Cerrar el diálogo
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                ref.read(todoListProvider.notifier).removeTodoAt(index);  // Eliminar tarea
                Navigator.of(context).pop();  // Cerrar el diálogo
              },
              child: const Text("Eliminar"),
            ),
                  ],
                );
              },
            );
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
