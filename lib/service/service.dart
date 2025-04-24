import 'dart:convert';
import 'package:http/http.dart' as http;

/// All todo API calls will be here
class TodoService {
  static Future<bool> deleteById(String id) async {
    try {
      final url = 'https://api.nstack.in/v1/todos/$id';
      final uri = Uri.parse(url);
      final response = await http.delete(uri);
      return response.statusCode == 200;
    } catch (e) {
      print('Delete error: $e');
      return false;
    }
  }

  static Future<List?> fetchTodos() async {
    try {
      final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return json['items'] as List;
      } else {
        return null;
      }
    } catch (e) {
      print('Fetch error: $e');
      return null;
    }
  }
}
