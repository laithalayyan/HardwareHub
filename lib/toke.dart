import 'package:get_storage/get_storage.dart';

Future<Map<String, String>> getHeaders() async {
  final storage = GetStorage();
  final String? token = storage.read('token'); // Retrieve the token

  if (token != null) {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token', // Add the token to the headers
    };
  } else {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }
}