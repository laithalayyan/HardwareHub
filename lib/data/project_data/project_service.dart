// import 'project_model.dart';
//
// class ProjectService {
//   static List<Project> getProjects() {
//     return [
//       Project(
//         id: 'proj1',
//         name: 'Home Automation System',
//         category: 'Automation',
//         imageUrls: [
//           'assets/images/projects/car_proj.jpg',
//           'assets/images/projects/smart_fan_proj.png',
//         ],
//         description: 'A smart home automation system that integrates lighting, security, and entertainment systems.',
//       ),
//       Project(
//         id: 'proj2',
//         name: 'Weather Monitoring System',
//         category: 'IoT',
//         imageUrls: [
//           'assets/images/projects/car_proj.jpg',
//           'assets/images/projects/smart_fan_proj.png',
//         ],
//         description: 'An IoT-based weather monitoring system with real-time data collection and visualization.',
//       ),
//       Project(
//         id: 'proj3',
//         name: 'Robotic Arm',
//         category: 'Robotics',
//         imageUrls: [
//           'assets/images/projects/car_proj.jpg',
//           'assets/images/projects/smart_fan_proj.png',
//         ],
//         description: 'A programmable robotic arm capable of performing precise movements for industrial automation.',
//       ),
//       Project(
//         id: 'proj4',
//         name: 'Mobile Banking App',
//         category: 'Mobile Development',
//         imageUrls: [
//           'assets/images/projects/car_proj.jpg',
//           'assets/images/projects/smart_fan_proj.png',
//         ],
//         description: 'A secure mobile banking application with features like money transfer, bill payment, and account management.',
//       ),
//     ];
//   }
// }

import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../config/config.dart';

class ProjectService {
  //final String baseUrl = '{{url}}/api/Category/CategoryProject';
  final storage = GetStorage(); // Initialize GetStorage

  Future<String?> _getToken() async {
    return storage.read('token'); // Retrieve the token
  }

  Future<List<Map<String, dynamic>>> fetchProjects() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/Projects'), // Use Config.baseUrl
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      //return List<Map<String, dynamic>>.from(json.decode(response.body));
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load projects: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/Category/CategoryProject/All'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Map<String, dynamic>>> fetchProjectsByCategory(String categoryId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/Category/CategoryProject/$categoryId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);
      if (responseData is Map<String, dynamic>) {
        final projects = responseData['projects'];
        if (projects is List) {
          return projects.cast<Map<String, dynamic>>();
        }
      }
      throw Exception('Invalid response format');
    } else {
      throw Exception('Failed to load projects');
    }
  }

  Future<Map<String, dynamic>> fetchProjectDetails(String projectId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/Projects/$projectId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load project details');
    }
  }

  Future<String> fetchOwnerUsername(String userId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/Auth/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['username']; // Assuming the response contains a 'username' field
    } else {
      throw Exception('Failed to load owner username: ${response.statusCode}');
    }
  }

}