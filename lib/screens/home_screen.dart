import 'package:flutter/material.dart';
import 'package:sample/screens/add_page.dart';
import 'package:sample/service/service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  List items = [];

  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📝 My Todo List"),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
              child: Text(
                'No tasks available. Tap ➕ to add!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            child: ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.all(12),
              itemBuilder:
                  (context, index) => buildTodoCard(items[index], index),
            ),
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAdd,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add),
        label: const Text("Add Task"),
      ),
    );
  }

  Widget buildTodoCard(Map<String, dynamic> item, int index) {
    final id = item['_id'];
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),

        title: Text(
          item['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text(item['description']),
        trailing: PopupMenuButton(
          onSelected: (value) {
            if (value == 'edit') {
              navigateToEditAdd(item);
            } else if (value == 'delete') {
              deleteById(id);
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'edit', child: Text('✏️ Edit')),
                const PopupMenuItem(value: 'delete', child: Text('🗑️ Delete')),
              ],
        ),
      ),
    );
  }

  Future<void> navigateToEditAdd(Map item) async {
    final route = MaterialPageRoute(builder: (context) => AddPage(todo: item));
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToAdd() async {
    final route = MaterialPageRoute(builder: (context) => const AddPage());
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteById(String id) async {
    final isSuccess = await TodoService.deleteById(id);
    if (isSuccess) {
      setState(() {
        items.removeWhere((element) => element['_id'] == id);
      });
      showSnackBar("Deleted successfully!", success: true);
    } else {
      showSnackBar('Deletion failed!', success: false);
    }
  }

  Future<void> fetchTodo() async {
    setState(() => isLoading = true);
    final response = await TodoService.fetchTodos();
    if (response != null) {
      setState(() {
        items = response;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      showSnackBar("Failed to load todos", success: false);
    }
  }

  void showSnackBar(String message, {required bool success}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
