import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddPage extends StatefulWidget {
  final Map? todo;
  const AddPage({super.key, this.todo});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  bool isEdit = false;

  TextEditingController textController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (todo != null) {
      isEdit = true;
      textController.text = todo['title'];
      descriptionController.text = todo['description'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '✏️ Edit Task' : 'Add New Task'),
        backgroundColor: Colors.deepPurpleAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: textController,
            decoration: InputDecoration(
              labelText: "Title",
              prefixIcon: const Icon(Icons.title),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: "Description",
              prefixIcon: const Icon(Icons.description),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: isEdit ? updateData : submitData,
            icon: Icon(isEdit ? Icons.update : Icons.send),
            label: Text(isEdit ? "Update Task" : "Add Task"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      showSnackBar('No data to update', success: false);
      return;
    }

    final id = todo['_id'];
    final body = {
      "title": textController.text,
      "description": descriptionController.text,
      "is_completed": false,
    };
    final uri = Uri.parse("https://api.nstack.in/v1/todos/$id");

    final response = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      showSnackBar("Task updated successfully!", success: true);
    } else {
      showSnackBar("Failed to update task!", success: false);
    }
  }

  Future<void> submitData() async {
    final body = {
      "title": textController.text,
      "description": descriptionController.text,
      "is_completed": false,
    };
    final uri = Uri.parse("https://api.nstack.in/v1/todos");

    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      textController.clear();
      descriptionController.clear();
      showSnackBar("Task created successfully!", success: true);
    } else {
      showSnackBar("Failed to create task!", success: false);
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
