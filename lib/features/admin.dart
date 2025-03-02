import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:t_store/chatHomePage.dart';
import 'package:t_store/utils/constants/colors.dart';

import '../NotificationsPage.dart';
import '../chat_service.dart';
import '../config/config.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/*
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();// Retrieve the username from storage
  final ChatService chatService = ChatService();

  final List<Widget> _pages = [
    const HomePage(),
    const ItemsPage(),
    const ProjectsPage(),
    const ChatHomePage(currentUserUsername: 'admin')
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    //Pop context here
    if(!kIsWeb) {
      Navigator.pop(context);
    }

  }


  @override
  Widget build(BuildContext context) {
    // Check if the app is running on the web
    final bool isWeb = kIsWeb;

    return Scaffold(
      //backgroundColor: const Color(0xff1B1F2B),
      key: _scaffoldKey,
      appBar: isWeb
          ? null // Hide the AppBar on web
          : AppBar(
        title: Text(
          'Admin Dashboard',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff2d3649),
        leading: isWeb
            ? null // Hide the menu icon on web
            : IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 25),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: isWeb
          ? null // Hide the drawer on web
          : Drawer(
        backgroundColor: const Color(0xff1B1F2B),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xff2d3649),
              ),
              child: Text(
                'Admin Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              selected: _selectedIndex == 0,
              selectedColor: const Color(0xff888888),
              selectedTileColor: const Color(0xff888888),
              onTap: () {
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Items'),
              selected: _selectedIndex == 1,
              selectedColor: const Color(0xff888888),
              selectedTileColor: const Color(0xff888888),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('Projects'),
              selected: _selectedIndex == 2,
              selectedColor: const Color(0xff888888),
              selectedTileColor: const Color(0xff888888),
              onTap: () {
                _onItemTapped(2);
                //Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat'),
              selected: _selectedIndex == 3,
              selectedColor: const Color(0xff888888),
              selectedTileColor: const Color(0xff888888),
              onTap: () {
                _onItemTapped(3);
                //Navigator.pop(context);
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.people),
            //   title: const Text('Users'),
            //   selected: _selectedIndex == 2,
            //   onTap: () {
            //     _onItemTapped(2);
            //     Navigator.pop(context);
            //   },
            // ),
          ],
        ),
      ),
      body: isWeb
          ? Row(
        children: [
          // Sidebar for web
          Container(
            width: 250, // Fixed width for the sidebar
            //color: const Color(0xff1B1F2B),
            color: const Color(0xff2d3649),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Reduced height for the DrawerHeader
                Container(
                  //color: const Color(0xff2d3649),
                  height: 100, // Reduced height
                  decoration: const BoxDecoration(
                    color: Color(0xff2d3649),
                  ),
                  child: const Center(
                    child: Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24, // Adjusted font size
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home, size: 21,),
                  title: const Text('Home', style: TextStyle(fontSize: 21,fontWeight: FontWeight.bold)),
                  selected: _selectedIndex == 0,
                  selectedColor: const Color(0xffa2a2a2),
                  selectedTileColor: const Color(0xffa2a2a2),
                  onTap: () {
                    _onItemTapped(0);
                  },
                ),
                const Divider(color: Colors.white,),
                ListTile(
                  leading: const Icon(Icons.inventory,size: 21,),
                  title: const Text('Items',style: TextStyle(fontSize: 21)),
                  selected: _selectedIndex == 1,
                  selectedColor: const Color(0xffa2a2a2),
                  selectedTileColor: const Color(0xffa2a2a2),
                  onTap: () {
                    _onItemTapped(1);
                  },
                ),
                const Divider(color: Colors.white,),
                ListTile(
                  leading: const Icon(Icons.work,size: 21,),
                  title: const Text('Projects',style: TextStyle(fontSize: 21)),
                  selected: _selectedIndex == 2,
                  selectedColor: const Color(0xffa2a2a2),
                  selectedTileColor: const Color(0xffa2a2a2),
                  onTap: () {
                    _onItemTapped(2);
                  },
                ),
                const Divider(color: Colors.white,),
                ListTile(
                  leading: const Icon(Icons.chat,size: 21, ),
                  title: const Text('Chat',style: TextStyle(fontSize: 21)),
                  selected: _selectedIndex == 3,
                  selectedColor: const Color(0xffa2a2a2),
                  selectedTileColor: const Color(0xffa2a2a2),
                  onTap: () {
                    _onItemTapped(3);
                    //Navigator.pop(context);
                  },
                ),
                // ListTile(
                //   leading: const Icon(Icons.people, color: Colors.white),
                //   title: const Text('Users', style: TextStyle(color: Colors.white)),
                //   selected: _selectedIndex == 2,
                //   onTap: () {
                //     _onItemTapped(2);
                //   },
                // ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Container(
              color: const Color(0xff1B1F2B), // Background color around the content
              child: Container(
                margin: const EdgeInsets.all(16), // Creates space around the content
                decoration: BoxDecoration(
                  color: const Color(0xff374151).withOpacity(0.9), // Semi-transparent background
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                child: _pages[_selectedIndex], // Your page content (ItemsPage, ProjectsPage, etc.)
              ),
            ),
          ),
        ],
      )
          : _pages[_selectedIndex], // Mobile layout
    );
  }
}
*/


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();// Retrieve the username from storage
  final ChatService chatService = ChatService();

  final List<Widget> _pages = [
    const HomePage(),
    const ItemsPage(),
    const ProjectsPage(),
    const ChatHomePage(currentUserUsername: 'admin'),
    const ReportsPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    //Pop context here
    if(!kIsWeb) {
      Navigator.pop(context);
    }

  }


  @override
  Widget build(BuildContext context) {
    // Check if the app is running on the web
    final bool isWeb = kIsWeb;

    return Scaffold(
      //backgroundColor: const Color(0xff1B1F2B),
      key: _scaffoldKey,
      appBar: isWeb
          ? null // Hide the AppBar on web
          : AppBar(
        title: Text(
          'Admin Dashboard',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff2d3649),
        leading: isWeb
            ? null // Hide the menu icon on web
            : IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 25),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: isWeb
          ? null // Hide the drawer on web
          : Drawer(
        backgroundColor: const Color(0xff1B1F2B),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xff2d3649),
              ),
              child: Text(
                'Admin Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              selected: _selectedIndex == 0,
              selectedColor: const Color(0xff888888),
              selectedTileColor: const Color(0xff888888),
              onTap: () {
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Items'),
              selected: _selectedIndex == 1,
              selectedColor: const Color(0xff888888),
              selectedTileColor: const Color(0xff888888),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('Projects'),
              selected: _selectedIndex == 2,
              selectedColor: const Color(0xff888888),
              selectedTileColor: const Color(0xff888888),
              onTap: () {
                _onItemTapped(2);
                //Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat'),
              selected: _selectedIndex == 3,
              selectedColor: const Color(0xff888888),
              selectedTileColor: const Color(0xff888888),
              onTap: () {
                _onItemTapped(3);
                //Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Reports'),
              selected: _selectedIndex == 4,
              selectedColor: const Color(0xff888888),
              selectedTileColor: const Color(0xff888888),
              onTap: () {
                _onItemTapped(4);
                //Navigator.pop(context);
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.people),
            //   title: const Text('Users'),
            //   selected: _selectedIndex == 2,
            //   onTap: () {
            //     _onItemTapped(2);
            //     Navigator.pop(context);
            //   },
            // ),
          ],
        ),
      ),
      body: isWeb
          ? Row(
        children: [
          // Sidebar for web
          Container(
            width: 250, // Fixed width for the sidebar
            //color: const Color(0xff1B1F2B),
            color: const Color(0xff2d3649),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Reduced height for the DrawerHeader
                Container(
                  //color: const Color(0xff2d3649),
                  height: 100, // Reduced height
                  decoration: const BoxDecoration(
                    color: Color(0xff2d3649),
                  ),
                  child: const Center(
                    child: Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24, // Adjusted font size
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home, size: 21,),
                  title: const Text('Home', style: TextStyle(fontSize: 21,fontWeight: FontWeight.bold)),
                  selected: _selectedIndex == 0,
                  selectedColor: const Color(0xffa2a2a2),
                  selectedTileColor: const Color(0xffa2a2a2),
                  onTap: () {
                    _onItemTapped(0);
                  },
                ),
                const Divider(color: Colors.white,),
                ListTile(
                  leading: const Icon(Icons.inventory,size: 21,),
                  title: const Text('Items',style: TextStyle(fontSize: 21)),
                  selected: _selectedIndex == 1,
                  selectedColor: const Color(0xffa2a2a2),
                  selectedTileColor: const Color(0xffa2a2a2),
                  onTap: () {
                    _onItemTapped(1);
                  },
                ),
                const Divider(color: Colors.white,),
                ListTile(
                  leading: const Icon(Icons.work,size: 21,),
                  title: const Text('Projects',style: TextStyle(fontSize: 21)),
                  selected: _selectedIndex == 2,
                  selectedColor: const Color(0xffa2a2a2),
                  selectedTileColor: const Color(0xffa2a2a2),
                  onTap: () {
                    _onItemTapped(2);
                  },
                ),
                const Divider(color: Colors.white,),
                ListTile(
                  leading: const Icon(Icons.chat,size: 21, ),
                  title: const Text('Chat',style: TextStyle(fontSize: 21)),
                  selected: _selectedIndex == 3,
                  selectedColor: const Color(0xffa2a2a2),
                  selectedTileColor: const Color(0xffa2a2a2),
                  onTap: () {
                    _onItemTapped(3);
                    //Navigator.pop(context);
                  },
                ),
                const Divider(color: Colors.white,),
                ListTile(
                  leading: const Icon(Icons.report,size: 21, ),
                  title: const Text('Reports',style: TextStyle(fontSize: 21)),
                  selected: _selectedIndex == 4,
                  selectedColor: const Color(0xffa2a2a2),
                  selectedTileColor: const Color(0xffa2a2a2),
                  onTap: () {
                    _onItemTapped(4);
                    //Navigator.pop(context);
                  },
                ),
                // ListTile(
                //   leading: const Icon(Icons.people, color: Colors.white),
                //   title: const Text('Users', style: TextStyle(color: Colors.white)),
                //   selected: _selectedIndex == 2,
                //   onTap: () {
                //     _onItemTapped(2);
                //   },
                // ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Container(
              color: const Color(0xff1B1F2B), // Background color around the content
              child: Container(
                margin: const EdgeInsets.all(16), // Creates space around the content
                decoration: BoxDecoration(
                  color: const Color(0xff374151).withOpacity(0.9), // Semi-transparent background
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                child: _pages[_selectedIndex], // Your page content (ItemsPage, ProjectsPage, etc.)
              ),
            ),
          ),
        ],
      )
          : _pages[_selectedIndex], // Mobile layout
    );
  }
}


////////////////// Report page////////////////////



class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}
class _ReportsPageState extends State<ReportsPage> {
  final GetStorage storage = GetStorage();
  List<dynamic> _reports = [];
  bool _isLoading = true;
  final http.Client _client = http.Client();

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    List<dynamic> loadedReports = [];

    try {
      // Fetch reports from the Shelf backend
      final response = await http.get(
        Uri.parse('http://192.168.10.93:3000/get-reports'),
      );

      if (response.statusCode == 200) {
        loadedReports = jsonDecode(response.body);
        print('Reports fetched from backend: $loadedReports');

        List<dynamic> completeReports = [];
        for (var report in loadedReports) {
          final itemDetails = await _fetchItemDetails(report['productId']);
          // Initialize newReport as a Map
          Map<String, dynamic> newReport = {
            ...report,
          };

          if (itemDetails != null &&
              itemDetails.containsKey('itemImageUrl') &&
              itemDetails.containsKey('name') &&
              itemDetails.containsKey('price')
          )
          {
            newReport = {
              ...newReport,
              'itemImageUrl': itemDetails['itemImageUrl'],
              'itemName': itemDetails['name'],
              'price': itemDetails['price'],
              'userId' : itemDetails['userId'],
              'timesUsed' : itemDetails['userId'],
              'date' : itemDetails['userId']
            };
          }

          completeReports.add(newReport);
        }

        setState(() {
          _reports = completeReports;
        });
        print('Final reports after item details: $_reports');
      } else {
        throw Exception('Failed to load reports: ${response.body}');
      }
    } catch (e) {
      print('Error loading reports: $e');
      setState(() {
        _reports = [];
      });
    }

    setState(() {
      _isLoading = false;
    });
  }


  Future<Map<String, dynamic>?> _fetchItemDetails(String itemId) async {
    final url = '${AppConfig.baseUrl}/api/Items/$itemId';
    final token = storage.read('token'); // Retrieve the token

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        print('Item details not found for item ID: $itemId');
        return null; // Return null for 404
      }else {
        print(
            'Failed to load item details. Status Code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load item details');
      }
    } catch (e) {
      print('Error fetching item details: $e');
      return null; // Return null on exception
    }
  }

  Future<List<dynamic>> _fetchReportsFromServer() async {
    final url = '${AppConfig.baseUrl}/get-reports';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> reports = jsonDecode(response.body);
        return reports;
      } else {
        print('Failed to load reports. Status Code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load reports from server');
      }
    } catch (e) {
      print('Error loading reports: $e');
      throw Exception('Failed to load reports from server: $e');
    }
  }



  Future<void> _deleteUser(String userId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this user?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false if cancelled
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true); // Return true if confirmed
              },
            ),
          ],
        );
      },
    ) ?? false;
    if(confirmDelete){
      final url = '${AppConfig.baseUrl}/api/Auth/$userId';
      final token = storage.read('token');

      try {
        final response = await _client.delete(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          _loadReports();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User Deleted')),
          );
        } else if (response.statusCode == 404) {
          print('User not found for user ID: $userId');
          return; // Exit if user not found
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error deleting user')),
          );
          print('Failed to delete User. Status Code: ${response.statusCode}');
          print('Response body: ${response.body}');
          throw Exception('Failed to delete User');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error deleting user')),
        );
        print('Error deleting user: $e');
        throw Exception('Failed to delete user: $e');
      }
    }

  }


  Future<Map<String, dynamic>> _fetchUserDetails(String userId) async {
    final url = '${AppConfig.baseUrl}/api/Auth/$userId';
    final token = storage.read('token'); // Retrieve the token

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load user details. Status Code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      print('Error fetching user details: $e');
      throw Exception('Failed to load user details: $e');
    }
  }

  Future<void> _deleteItem(String itemId, String imageUrl) async {

    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false if cancelled
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true); // Return true if confirmed
              },
            ),
          ],
        );
      },
    ) ?? false;

    if(confirmDelete){
      final url = '${AppConfig.baseUrl}/api/Items/$itemId';
      final token = storage.read('token');

      try {
        final response = await _client.delete(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          // Remove item from local storage
          List<dynamic> currentReports = [];
          final reportsString = storage.read('reports');
          if (reportsString != null) {
            try {
              currentReports = jsonDecode(reportsString);
            } catch (e) {
              print("Error decoding current reports: $e");
            }
          }
          currentReports.removeWhere((report) => report['productId'] == itemId);
          await storage.write('reports', jsonEncode(currentReports));
          if (imageUrl.isNotEmpty) {
            await _deleteImageFromS3(imageUrl); // Deleting the image from s3
          }
          _loadReports();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item Deleted')),
          );
        }  else if (response.statusCode == 404) {
          print('Item details not found for item ID: $itemId');
          return; // Return if item not found
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error deleting item')),
          );
          print('Failed to delete item. Status Code: ${response.statusCode}');
          print('Response body: ${response.body}');
          throw Exception('Failed to delete item');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error deleting item')),
        );
        print('Error deleting item: $e');
        throw Exception('Failed to delete item: $e');
      }
    }
  }

  Future<void> _deleteImageFromS3(String imageUrl) async {
    final String s3Key = imageUrl.split('/').last;
    final url =  '${AppConfig.baseUrl}/api/AWS/DeleteImage?key=$s3Key';
    final token = storage.read('token');
    try {
      final response = await _client.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        print('Image deleted from S3');
      } else {
        print('Failed to delete image from S3. Status code: ${response.statusCode}, response body :${response.body}');
        throw Exception('Failed to delete image from S3');
      }
    } catch (e) {
      print('Error deleting image from S3: $e');
      throw Exception('Failed to delete image from S3: $e');
    }
  }

  void _showItemDetailsDialog(BuildContext context, dynamic itemData) {
    if (itemData is Map<String, dynamic> && itemData.containsKey('itemName')) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return _ItemDetailsDialog(itemData: itemData);
        },
      );
    } else {
      print('Invalid item data: $itemData');
    }
  }

  void _showOwnerDetailsDialog(BuildContext context, dynamic userId) {
    if (userId is String) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return _OwnerDetailsDialog(userId: userId);
        },
      );
    } else {
      print('Invalid user ID: $userId');
    }
  }

  void _showReportDetailsDialog(BuildContext context, dynamic report) {
    if (report is Map<String, dynamic> && report.containsKey('itemName')) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return _ReportDetailsDialog(report: report);
        },
      );
    } else {
      print('Invalid report data: $report');
    }
  }


  String _formatTimeAgo(String timestamp) {
    final parsedTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(parsedTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    }else{
      return 'Just now';
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff374151),
      appBar: AppBar(title: const Text('Reports' ,style: TextStyle(fontSize: 25),)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
          ? const Center(child: Text('No reports found.'))
          : ListView.builder(
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image on the left
                  if (report.containsKey('itemImageUrl') && report['itemImageUrl'] != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Image.network(report['itemImageUrl'], width: 100, height: 100, fit: BoxFit.cover),
                    ),
                  // Text and Buttons on the right
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${report['itemName']}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Price: \$${report['price']}',
                            style: const TextStyle(fontSize: 16)),
                        if(report.containsKey('timestamp'))
                          Text('Reported ${_formatTimeAgo(report['timestamp'])}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 8),
                        // Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _deleteItem(report['productId'], report['itemImageUrl']);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('   Delete Item   ', style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _deleteUser(report['userId']);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('   Delete User   ', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (report['itemName'] != null) {
                                    _showItemDetailsDialog(context, report);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Item details not available')),
                                    );
                                  }
                                },
                                child: const Text('   Show Item Details   '),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _showOwnerDetailsDialog(context, report['userId']);
                                },
                                child: const Text('   Show Owner Details  '),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _showReportDetailsDialog(context, report);
                                },
                                child: const Text('  Show Report Details  '),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}

class _ItemDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> itemData;
  _ItemDetailsDialog({required this.itemData});

  @override
  _ItemDetailsDialogState createState() => _ItemDetailsDialogState();
}
class _ItemDetailsDialogState extends State<_ItemDetailsDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Item Details'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            if (widget.itemData.containsKey('itemImageUrl') && widget.itemData['itemImageUrl'] != null)
              Image.network(widget.itemData['itemImageUrl'], height: 100, width: 100),
            Text('Name: ${widget.itemData['itemName']}'), // Use 'itemName' here
            Text('Price: \$${widget.itemData['price']}'),
            //Text('Times Used: ${widget.itemData['timesUsed'] ?? 2}'),
            Text('Count: ${widget.itemData['count'] ?? '3'}'),
            //Text('Date: ${widget.itemData['date'] ?? 2/4/2025}'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class _OwnerDetailsDialog extends StatefulWidget {
  final String userId;
  _OwnerDetailsDialog({required this.userId});

  @override
  _OwnerDetailsDialogState createState() => _OwnerDetailsDialogState();
}
class _OwnerDetailsDialogState extends State<_OwnerDetailsDialog> {
  final GetStorage storage = GetStorage();
  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> _fetchUserDetails(String userId) async {
    final url = '${AppConfig.baseUrl}/api/Auth/$userId';
    final token = storage.read('token'); // Retrieve the token
    try {
      final response = await _client.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
          }
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load user details. Status Code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      print('Error fetching user details: $e');
      throw Exception('Failed to load user details: $e');
    }
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return  FutureBuilder<Map<String, dynamic>>(
      future: _fetchUserDetails(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Text('No owner data found');
        } else {
          final ownerData = snapshot.data!;
          return AlertDialog(
            title: const Text('Owner Details'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('Username: ${ownerData['username']}'),
                  Text('Email: ${ownerData['email']}'),
                  Text('First Name: ${ownerData['firstName'] ?? 'N/A'}'),
                  Text('Last Name: ${ownerData['lastName'] ?? 'N/A'}'),
                  Text('Phone Number: ${ownerData['phoneNumber'] ?? 'N/A'}'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
      },
    );
  }
}

class _ReportDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> report;
  _ReportDetailsDialog({required this.report});

  @override
  _ReportDetailsDialogState createState() => _ReportDetailsDialogState();
}
class _ReportDetailsDialogState extends State<_ReportDetailsDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report Details'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text('Product Name: ${widget.report['itemName']}'),
            if (widget.report.containsKey('itemImageUrl') && widget.report['itemImageUrl'] != null)
              Image.network(widget.report['itemImageUrl'], height: 100, width: 100),
            Text('Selected Problem: ${widget.report['selectedProblem'] ?? 'N/A'}'),
            Text('Other Reasons: ${widget.report['otherReasons'] ?? 'N/A'}'),
            Text('Reported at: ${widget.report['timestamp']}'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}


/////////////////// Home Page /////////////////////

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final box = GetStorage();
  late Future<List<dynamic>> futurePurchases;
  late Future<List<dynamic>> futureItems;
  late Future<List<dynamic>> futureProjects;
  late Future<Map<String, dynamic>> futureRange;
  late int _selectedMinYear;
  late int _selectedMaxYear;

  @override
  void initState() {
    super.initState();
    futurePurchases = fetchPurchaseData();
    futureItems = fetchItemsData();
    futureProjects = fetchProjectsData();
    futureRange = fetchRangeData();
    _selectedMinYear = 100;
    _selectedMaxYear = 200;


  }


  Future<Map<String, dynamic>> fetchRangeData() async {
    final token = box.read('token');
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/Range/GetRange'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _selectedMinYear = data['min'];
        _selectedMaxYear = data['max'];

      });
      return data;
    } else {
      throw Exception('Failed to load range data');
    }
  }
  Future<void> _updateRange() async {
    final token = box.read('token');
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/Range/AddRange'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'min': _selectedMinYear,
          'max': _selectedMaxYear,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Range Updated successfully')));
        setState(() {
          futureRange = Future.value(data);
        });

      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update range ${response.body}')));
        throw Exception('Failed to update range');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('An error occurred: $e')));
    }
  }
  Future<List<dynamic>> fetchPurchaseData() async {
    final token = box.read('token');
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/Purchase/All'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load purchase data');
    }
  }

  Future<List<dynamic>> fetchItemsData() async {
    final token = box.read('token');
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/Items'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load items data');
    }
  }
  Future<List<dynamic>> fetchProjectsData() async {
    final token = box.read('token');
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/Projects'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load projects data');
    }
  }


  Future<double> fetchAverageGrade(String itemId) async {
    final token = box.read('token');
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/Review/Item/$itemId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['averageGrade'] ?? 0.0;
    } else {
      throw Exception('Failed to load reviews for item $itemId');
    }
  }

  Map<String, int> countItemOccurrences(List<dynamic> purchases) {
    Map<String, int> itemCounts = {};

    for (var purchase in purchases) {
      String itemName = purchase['item']['name'];
      itemCounts[itemName] = (itemCounts[itemName] ?? 0) + 1;
    }

    return itemCounts;
  }

  // OverlayEntry to show the custom tooltip
  OverlayEntry? _tooltipEntry;

  // Function to show the custom tooltip
  void _showTooltip(BuildContext context, String itemName, int purchaseCount, String imageUrl, Offset position) {
    // Remove the existing tooltip if it's already showing
    _tooltipEntry?.remove();

    // Create a new OverlayEntry for the tooltip
    _tooltipEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy,
        child: Material(
          color: Colors.transparent,
          child: CustomTooltip(
            itemName: itemName,
            purchaseCount: purchaseCount,
            imageUrl: imageUrl,
          ),
        ),
      ),
    );

    // Insert the tooltip into the overlay
    Overlay.of(context).insert(_tooltipEntry!);
  }

  // Function to hide the custom tooltip
  void _hideTooltip() {
    _tooltipEntry?.remove();
    _tooltipEntry = null;
  }

  // Helper function to calculate the angle for each section
  double _calculateAngle(int index, int totalSections) {
    return (index / totalSections) * 2 * 3.14159; // Convert to radians
  }

// Helper function to calculate the offset for positioning the indicators
  Offset _calculateOffset(double angle, double distanceFromCenter) {
    return Offset(
      distanceFromCenter * cos(angle),
      distanceFromCenter * sin(angle),
    );
  }

  Future<Map<String, String>> fetchUserNames(List<dynamic> projects) async {
    final token = box.read('token');
    Map<String, String> userNames = {};
    for (var project in projects) {
      final userId = project['userId'];
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/Auth/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        userNames[userId] = userData['username'] ?? 'Unknown';
      }
    }
    return userNames;
  }


  Map<String, int> countProjectPosters(List<dynamic> projects) {
    Map<String, int> userProjectCounts = {};

    for (var project in projects) {
      String userId = project['userId'];
      userProjectCounts[userId] = (userProjectCounts[userId] ?? 0) + 1;
    }
    return userProjectCounts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder<Map<String, dynamic>>(
          future: futureRange,
          builder: (context, rangeSnapshot){
            if (rangeSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (rangeSnapshot.hasError) {
              return Center(child: Text('Error: ${rangeSnapshot.error}'));
            } else {
              return Column(
                children: [
                  // Year Range Selection
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:  Column(
                      children: [
                        const Text(
                          'The acceptable year range :',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('From: ', style: TextStyle(fontSize: 16, color: Colors.white)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<int>(
                                value: _selectedMinYear,
                                dropdownColor: Colors.grey[800],
                                items: List.generate(
                                  101,
                                      (index) => DropdownMenuItem(
                                    value: 100 + index,
                                    child: Text((100 + index).toString(), style: const TextStyle(color: Colors.white)),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value != null && value < _selectedMaxYear ) {
                                    setState(() => _selectedMinYear = value);
                                  }else{
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('min year must be less than max year')));
                                  }
                                },
                                underline: Container(),
                              ),
                            ),
                            const SizedBox(width: 20),
                            const Text('To: ', style: TextStyle(fontSize: 16, color: Colors.white)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<int>(
                                value: _selectedMaxYear,
                                dropdownColor: Colors.grey[800],
                                items: List.generate(
                                  101,
                                      (index) => DropdownMenuItem(
                                    value: 100 + index,
                                    child: Text((100 + index).toString(), style: const TextStyle(color: Colors.white)),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value != null && value > _selectedMinYear) {
                                    setState(() => _selectedMaxYear = value);
                                  } else{
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('max year must be greater than min year')));
                                  }
                                },
                                underline: Container(),
                              ),
                            ),

                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _updateRange,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0), // Adjust the padding values as needed
                                child: Text('Save Range', style: TextStyle(color: Colors.white)),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder<List<dynamic>>(
                    future: futurePurchases,
                    builder: (context, purchaseSnapshot) {
                      if (purchaseSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (purchaseSnapshot.hasError) {
                        return Center(child: Text('Error: ${purchaseSnapshot.error}'));
                      } else if (!purchaseSnapshot.hasData || purchaseSnapshot.data!.isEmpty) {
                        return const Center(child: Text('No purchase data available'));
                      } else {
                        final itemCounts = countItemOccurrences(purchaseSnapshot.data!);

                        // Sort items by count in ascending order
                        final sortedEntries = itemCounts.entries.toList()
                          ..sort((b, a) => a.value.compareTo(b.value));

                        return FutureBuilder<List<dynamic>>(
                          future: futureItems,
                          builder: (context, itemsSnapshot) {
                            if (itemsSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (itemsSnapshot.hasError) {
                              return Center(child: Text('Error: ${itemsSnapshot.error}'));
                            } else if (!itemsSnapshot.hasData || itemsSnapshot.data!.isEmpty) {
                              return const Center(child: Text('No items data available'));
                            } else {
                              return FutureBuilder<List<dynamic>>(
                                  future: futureProjects,
                                  builder: (context, projectsSnapshot) {
                                    if (projectsSnapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    } else if (projectsSnapshot.hasError) {
                                      return Center(child: Text('Error: ${projectsSnapshot.error}'));
                                    } else if (!projectsSnapshot.hasData || projectsSnapshot.data!.isEmpty) {
                                      return const Center(child: Text('No project data available'));
                                    } else{

                                      final itemPostCounts = countItemPosters(itemsSnapshot.data!);
                                      final projectCounts = countProjectPosters(projectsSnapshot.data!);

                                      Map<String, int> combinedCounts = {};
                                      projectCounts.forEach((key, value) {
                                        combinedCounts[key] = (combinedCounts[key] ?? 0) + value;
                                      });
                                      itemPostCounts.forEach((key, value) {
                                        combinedCounts[key] = (combinedCounts[key] ?? 0) + value;
                                      });

                                      final sortedCombinedEntries = combinedCounts.entries.toList()
                                        ..sort((a, b) => b.value.compareTo(a.value));

                                      return FutureBuilder<Map<String, String>>(
                                          future: fetchUserNames(projectsSnapshot.data!),
                                          builder: (context, userNamesSnapshot) {
                                            if (userNamesSnapshot.connectionState == ConnectionState.waiting) {
                                              return const Center(child: CircularProgressIndicator());
                                            } else if (userNamesSnapshot.hasError) {
                                              return Center(child: Text('Error: ${userNamesSnapshot.error}'));
                                            } else if (!userNamesSnapshot.hasData || userNamesSnapshot.data!.isEmpty) {
                                              return const Center(child: Text('No users data available'));
                                            } else {
                                              final userNames = userNamesSnapshot.data!;
                                              return  Column(
                                                children: [
                                                  // Top Purchased Items Bar Chart
                                                  Container(
                                                    padding: const EdgeInsets.all(16),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[900],
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        const Text(
                                                          'Top Purchased Items',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 16),
                                                        SizedBox(
                                                          height: 400,
                                                          child: BarChart(
                                                            BarChartData(
                                                              barGroups: sortedEntries.take(6).map((entry) {
                                                                return BarChartGroupData(
                                                                  x: sortedEntries.indexOf(entry),
                                                                  barRods: [
                                                                    BarChartRodData(
                                                                      fromY: 0,
                                                                      toY: entry.value.toDouble(),
                                                                      //color: Colors.blueAccent,
                                                                      color: TColors.primary,
                                                                      width: 40,
                                                                      borderRadius: BorderRadius.circular(4),
                                                                    ),
                                                                  ],
                                                                );
                                                              }).toList(),
                                                              titlesData: FlTitlesData(
                                                                bottomTitles: AxisTitles(
                                                                  sideTitles: SideTitles(
                                                                    showTitles: true,
                                                                    getTitlesWidget: (value, meta) {
                                                                      return Text(
                                                                        sortedEntries[value.toInt()].key,
                                                                        style: const TextStyle(
                                                                          color: Colors.white,
                                                                          fontSize: 12,
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                                leftTitles: AxisTitles(
                                                                  sideTitles: SideTitles(
                                                                    showTitles: true,
                                                                    getTitlesWidget: (value, meta) {
                                                                      return Text(
                                                                        value.toInt().toString(),
                                                                        style: const TextStyle(
                                                                          color: Colors.white,
                                                                          fontSize: 12,
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                              borderData: FlBorderData(show: false),
                                                              barTouchData: BarTouchData(
                                                                enabled: true,
                                                                touchCallback: (event, response) {
                                                                  if (response != null && response.spot != null) {
                                                                    final entry = sortedEntries[response.spot!.touchedBarGroupIndex];
                                                                    final imageUrl = purchaseSnapshot.data!
                                                                        .firstWhere((purchase) => purchase['item']['name'] == entry.key)['item']['itemImageUrl'];

                                                                    // Get the position of the touch
                                                                    final position = Offset(
                                                                      event.localPosition!.dx + 240,
                                                                      event.localPosition!.dy - 150, // Adjust the vertical position
                                                                    );

                                                                    // Show the custom tooltip
                                                                    _showTooltip(context, entry.key, entry.value, imageUrl, position);
                                                                  } else {
                                                                    // Hide the tooltip when there's no touch
                                                                    _hideTooltip();
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  // Row containing the Top Project Posters Bar Chart and Pie Chart
                                                  Row(
                                                    children: [
                                                      // Top Project Posters Bar Chart
                                                      Expanded(
                                                        child: Container(
                                                          padding: const EdgeInsets.all(16),
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey[900],
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              const Text(
                                                                'Top Active Users',
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 16),
                                                              SizedBox(
                                                                height: 300,
                                                                child: BarChart(
                                                                  BarChartData(
                                                                    barGroups: sortedCombinedEntries.take(5).toList().asMap().entries.map((entry) {
                                                                      final index = entry.key;
                                                                      final combinedEntry = entry.value;
                                                                      return BarChartGroupData(
                                                                        x: index,
                                                                        barRods: [
                                                                          BarChartRodData(
                                                                            fromY: 0,
                                                                            toY: combinedEntry.value.toDouble(),
                                                                            color: Colors.primaries[index % Colors.primaries.length],
                                                                            width: 40,
                                                                          ),
                                                                        ],
                                                                      );
                                                                    }).toList(),
                                                                    titlesData: FlTitlesData(
                                                                      bottomTitles: AxisTitles(
                                                                        sideTitles: SideTitles(
                                                                          showTitles: true,
                                                                          getTitlesWidget: (value, meta) {
                                                                            final userIndex = value.toInt();
                                                                            if(userIndex < sortedCombinedEntries.length) {
                                                                              final userId = sortedCombinedEntries[userIndex].key;
                                                                              return Text(
                                                                                userNames[userId] ?? 'Unknown',
                                                                                style: const TextStyle(color: Colors.white,fontSize: 10),
                                                                              );
                                                                            }
                                                                            return const Text('');
                                                                          },
                                                                        ),
                                                                      ),
                                                                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                                                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                                                    ),
                                                                    borderData: FlBorderData(show: false),
                                                                    barTouchData: BarTouchData(enabled: false), // Disable touch interaction
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      // Pie Chart
                                                      Expanded(
                                                        child: Container(
                                                          padding: const EdgeInsets.all(16),
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey[900],
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          child:  FutureBuilder<List<double>>(
                                                            future: Future.wait(
                                                              itemsSnapshot.data!.map((item) => fetchAverageGrade(item['id'])).toList(),
                                                            ),
                                                            builder: (context, averageGradesSnapshot) {
                                                              if (averageGradesSnapshot.connectionState == ConnectionState.waiting) {
                                                                return const Center(child: CircularProgressIndicator());
                                                              } else if (averageGradesSnapshot.hasError) {
                                                                return Center(child: Text('Error: ${averageGradesSnapshot.error}'));
                                                              } else if (!averageGradesSnapshot.hasData || averageGradesSnapshot.data!.isEmpty) {
                                                                return const Center(child: Text('No reviews data available'));
                                                              } else {
                                                                final List<PieChartSectionData> pieChartSections = [];
                                                                for (int i = 0; i < itemsSnapshot.data!.length; i++) {
                                                                  final item = itemsSnapshot.data![i];
                                                                  final averageGrade = averageGradesSnapshot.data![i];
                                                                  pieChartSections.add(
                                                                    PieChartSectionData(
                                                                      value: averageGrade,
                                                                      color: Colors.primaries[i % Colors.primaries.length],
                                                                      radius: 80,
                                                                      title: '${item['name']}\n${averageGrade.toStringAsFixed(1)}',
                                                                      titleStyle: const TextStyle(
                                                                        fontSize: 12,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: Colors.white,
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                      titlePositionPercentageOffset: 0.4, // Adjust this to move text into the section
                                                                    ),
                                                                  );
                                                                }

                                                                return  Column(
                                                                  children: [
                                                                    const Text(
                                                                      'Top Reviewed Items',
                                                                      style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontSize: 18,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(height: 16),
                                                                    SizedBox(
                                                                      height: 300,
                                                                      child: PieChart(
                                                                        PieChartData(
                                                                          sections: pieChartSections,
                                                                          borderData: FlBorderData(show: true),
                                                                          sectionsSpace: 0,
                                                                          centerSpaceRadius: 80,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            }
                                          }
                                      );
                                    }
                                  }
                              );
                            }
                          },
                        );
                      }
                    },
                  ),
                ],
              );
            }

          },
        ),
      ),
    );
  }
  Map<String, int> countItemPosters(List<dynamic> items) {
    Map<String, int> userItemCounts = {};

    for (var item in items) {
      String userId = item['userId'];
      userItemCounts[userId] = (userItemCounts[userId] ?? 0) + 1;
    }
    return userItemCounts;
  }
}

/// Custom Tooltip Widget
class CustomTooltip extends StatelessWidget {
  final String itemName;
  final int purchaseCount;
  final String imageUrl;

  const CustomTooltip({
    Key? key,
    required this.itemName,
    required this.purchaseCount,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(
            imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 8),
          Text(
            itemName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Purchased: $purchaseCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/////////////////// Items Page /////////////////////

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final GetStorage _storage = GetStorage();
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = []; // Filtered items based on category and search
  final ImagePicker _picker = ImagePicker();
  String? _selectedCategory; // To keep track of the selected category
  final TextEditingController _searchController = TextEditingController(); // Controller for the search bar


  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    final token = _storage.read('token');
    final url = '${AppConfig.baseUrl}/api/Items';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _items = data.cast<Map<String, dynamic>>();
          _filteredItems = List.from(_items);
        });
        // Fetch categories after items are loaded
        await _fetchCategories();
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch items: $e');
    }
  }

  List<Map<String, dynamic>> _categories = [];

  Future<void> _fetchCategories() async {
    final token = _storage.read('token');
    final url = '${AppConfig.baseUrl}/api/Category/CategoryItem/All';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _categories = data.cast<Map<String, dynamic>>();
          _categories.insert(0, {'id':'all','name':'All'}); // add All option
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch categories: $e');
    }
  }

  String _getCategoryName(String categoryItemId) {
    final category = _categories.firstWhere(
          (category) => category['id'] == categoryItemId,
      orElse: () => {'name': 'Unknown'}, // Default if category is not found
    );
    return category['name'];
  }
  void _filterItems({String? searchQuery, String? categoryId}) {
    setState(() {
      _filteredItems = _items.where((item) {
        // If a category is selected, ensure the item belongs to that category
        bool categoryMatch = true;
        if (categoryId != null && categoryId != 'all') {
          categoryMatch = item['categoryItemId'] == categoryId;
        }
        // If a search query is present, ensure item name contains it.
        bool searchMatch = true;
        if (searchQuery != null && searchQuery.isNotEmpty) {
          searchMatch = item['name'].toLowerCase().contains(searchQuery.toLowerCase());
        }
        // Items must match both filters
        return categoryMatch && searchMatch;
      }).toList();
    });
  }


  Future<void> _deleteItem(String itemId) async {
    final token = _storage.read('token');
    final url = '${AppConfig.baseUrl}/api/Items/$itemId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _fetchItems(); // Refresh the list
        Get.snackbar('Success', 'Item deleted successfully');
      } else {
        throw Exception('Failed to delete item');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete item: $e');
    }
  }

  Future<String?> _uploadImage(File image) async {
    final token = _storage.read('token');
    final url = '${AppConfig.baseUrl}/api/Upload/upload';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('files', image.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final imageUrl = jsonDecode(responseData)[0]; // Assuming the response is a list with the URL at index 0
        return imageUrl; // Return the image URL
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e');
      return null; // Return null if there's an error
    }
  }

  void _showAddItemDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController timesUsedController = TextEditingController();
    final TextEditingController countController = TextEditingController();
    File? _imageFile;

    String? selectedCategoryId;
    String? selectedSubCategoryId;
    List<Map<String, dynamic>> _subCategories = [];

    Get.dialog(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Add Item', style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xff374151),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  // Name Field
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),

                  // Price Field
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),

                  // Times Used Field
                  TextField(
                    controller: timesUsedController,
                    decoration: InputDecoration(
                      labelText: 'Times Used',
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),

                  // Count Field
                  TextField(
                    controller: countController,
                    decoration: InputDecoration(
                      labelText: 'Count',
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    items: _categories.map<DropdownMenuItem<String>>((category) {
                      return DropdownMenuItem<String>(
                        value: category['id'], // Ensure this is a String
                        child: Text(
                          category['name'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategoryId = value;
                        selectedSubCategoryId = null; // Reset subcategory selection
                        // Find the selected category and get its subcategories
                        final selectedCategory = _categories.firstWhere(
                              (category) => category['id'] == value,
                          orElse: () => {'subCategories': []}, // Default to an empty list
                        );
                        _subCategories = (selectedCategory['subCategories'] as List<dynamic>)
                            .cast<Map<String, dynamic>>();
                        //_subCategories = selectedCategory['subCategories'] ?? [];
                      });

                      // Debugging: Print selected category and subcategories
                      print('Selected Category: $selectedCategoryId');
                      print('Subcategories: $_subCategories');
                    },
                  ),
                  const SizedBox(height: 16),

                  // Subcategory Dropdown (only shown if subcategories exist)
                  if (_subCategories.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: selectedSubCategoryId,
                      decoration: InputDecoration(
                        labelText: 'Subcategory',
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      items: _subCategories.map<DropdownMenuItem<String>>((subCategory) {
                        return DropdownMenuItem<String>(
                          value: subCategory['id'], // Ensure this is a String
                          child: Text(
                            subCategory['name'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSubCategoryId = value;
                        });
                      },
                    ),
                  const SizedBox(height: 16),

                  // Upload Image Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        final image = await _picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            _imageFile = File(image.path);
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        'Upload Image',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () async {
                  if (_imageFile == null) {
                    Get.snackbar('Error', 'Please upload an image');
                    return;
                  }

                  final imageUrl = await _uploadImage(_imageFile!); // Await the result
                  if (imageUrl == null) return; // Handle null case

                  final newItem = {
                    "name": nameController.text,
                    "price": int.parse(priceController.text),
                    "timesUsed": int.parse(timesUsedController.text),
                    "count": int.parse(countController.text),
                    "itemImageUrl": imageUrl,
                    "categoryItemId": selectedCategoryId, // Use the selected category ID
                    "subCategoryItemId": selectedSubCategoryId, // Use the selected subcategory ID
                  };

                  final token = _storage.read('token');
                  final url = '${AppConfig.baseUrl}/api/Items';

                  try {
                    final response = await http.post(
                      Uri.parse(url),
                      headers: {
                        'Authorization': 'Bearer $token',
                        'Content-Type': 'application/json',
                      },
                      body: jsonEncode(newItem),
                    );

                    if (response.statusCode == 200) {
                      _fetchItems(); // Refresh the list
                      Get.back();
                      Get.snackbar('Success', 'Item added successfully');
                    } else {
                      throw Exception('Failed to add item');
                    }
                  } catch (e) {
                    Get.snackbar('Error', 'Failed to add item: $e');
                  }
                },
                child: const Text('Add', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditItemDialog(Map<String, dynamic> item) async {
    final TextEditingController nameController = TextEditingController(text: item['name']);
    final TextEditingController priceController = TextEditingController(text: item['price'].toString());
    final TextEditingController timesUsedController = TextEditingController(text: item['timesUsed'].toString());
    final TextEditingController countController = TextEditingController(text: item['count'].toString());
    File? _imageFile;

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Item', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff374151),
        content: SingleChildScrollView(
          child: Column(
            children: [
              // Name Field
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Price Field
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Times Used Field
              TextField(
                controller: timesUsedController,
                decoration: InputDecoration(
                  labelText: 'Times Used',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Count Field
              TextField(
                controller: countController,
                decoration: InputDecoration(
                  labelText: 'Count',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Upload Image Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    final image = await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        _imageFile = File(image.path);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Upload Image',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              String? imageUrl = item['itemImageUrl'];
              if (_imageFile != null) {
                imageUrl = await _uploadImage(_imageFile!); // Await the result
                if (imageUrl == null) return; // Handle null case
              }

              final updatedItem = {
                "name": nameController.text,
                "price": int.parse(priceController.text),
                "timesUsed": int.parse(timesUsedController.text),
                "count": int.parse(countController.text),
                "itemImageUrl": imageUrl, // Use the returned image URL
              };

              final token = _storage.read('token');
              final url = '${AppConfig.baseUrl}/api/Items/${item['id']}';

              try {
                final response = await http.put(
                  Uri.parse(url),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode(updatedItem),
                );

                if (response.statusCode == 200) {
                  _fetchItems(); // Refresh the list
                  Get.back();
                  Get.snackbar('Success', 'Item updated successfully');
                } else {
                  throw Exception('Failed to update item');
                }
              } catch (e) {
                Get.snackbar('Error', 'Failed to update item: $e');
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      //backgroundColor: const Color(0xff1B1F2B), // Background color for the page
      floatingActionButton: FloatingActionButton(
        //backgroundColor: const Color(0xff1B1F2B),
        backgroundColor: const Color(0xff2d3649),
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add, size: 39),
      ),
      body:
      Container(
          margin: const EdgeInsets.all(16), // Add margin for better spacing
          padding: const EdgeInsets.all(16), // Add padding for better spacing
          decoration: BoxDecoration(
            color: const Color(0xff374151), // Different background color for the items list
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      items: _categories.map<DropdownMenuItem<String>>((category) {
                        return DropdownMenuItem<String>(
                          value: category['id'],
                          child: Text(category['name'], style: const TextStyle(color: Colors.white),),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                          _filterItems(categoryId: value); // Apply filter on category change
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search',
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value){
                        _filterItems(searchQuery: value, categoryId: _selectedCategory);
                      } ,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    final categoryName = _getCategoryName(item['categoryItemId']);
                    return Card(
                      color: const Color(0xff2d3649),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: item['itemImageUrl'] != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item['itemImageUrl'],
                            width: 70,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                            : const Icon(Icons.image, size: 50, color: Colors.white),
                        title: Text(
                          item['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          'Category: $categoryName',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditItemDialog(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteItem(item['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
      ),
    );
  }
}

/////////////////// Projects Page /////////////////////

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final GetStorage _storage = GetStorage();
  List<Map<String, dynamic>> _projects = [];

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    final token = _storage.read('token');
    final url = '${AppConfig.baseUrl}/api/Projects';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _projects = data.cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception('Failed to load projects');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch projects: $e');
    }
  }

  Future<String?> _uploadImage(File image) async {
    final token = _storage.read('token');
    final url = '${AppConfig.baseUrl}/api/Upload/upload';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('files', image.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final imageUrl = jsonDecode(responseData)[0]; // Assuming the response is a list with the URL at index 0
        return imageUrl; // Return the image URL
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e');
      return null; // Return null if there's an error
    }
  }


  void _showProjectDetails(Map<String, dynamic> project) async {
    final GetStorage _storage = GetStorage();
    final token = _storage.read('token');
    final url = '${AppConfig.baseUrl}/api/Projects/${project['id']}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final projectDetails = jsonDecode(response.body);
        final projectImageUrls = projectDetails['projectImageUrl'] ?? [];
        final items = projectDetails['items'] ?? [];

        Get.dialog(
          Dialog(
            backgroundColor: const Color(0xff374151),
            child: Container(
              //height: 200,
              width: 600, // Fixed width for the dialog
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      projectDetails['name'] ?? 'Unnamed Project',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Description: ${projectDetails['description'] ?? 'No description'}',
                      style: const TextStyle(color: Colors.white),
                      softWrap: true, // Ensure text wraps
                      maxLines: null, // Allow unlimited lines
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cost: \$${projectDetails['cost'] ?? '0'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Owner: ${projectDetails['user']?['username'] ?? 'Unknown'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Images:',
                      style: TextStyle(color: Colors.white),
                    ),
                    if (projectImageUrls.isEmpty)
                      const Text(
                        'No images available.',
                        style: TextStyle(color: Colors.white),
                      )
                    else
                      SizedBox(
                        height: 100, // Fixed height for images
                        //width: 600, // Fixed width for the ListView
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: projectImageUrls.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.network(
                                projectImageUrls[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    const Text(
                      'Items:',
                      style: TextStyle(color: Colors.white),
                    ),
                    if (items.isEmpty)
                      const Text(
                        'No items available.',
                        style: TextStyle(color: Colors.white),
                      )
                    else
                      SizedBox(
                        height: 120, // Fixed height for items
                        //width: 200, // Fixed width for the ListView
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Image.network(
                                    item['itemImageUrl'] ?? '',
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['name'] ?? 'Unnamed Item',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      } else {
        throw Exception('Failed to load project details');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch project details: $e');
    }
  }

  void _showAddProjectDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController costController = TextEditingController();
    List<String> imageUrls = [];

    Get.dialog(
      AlertDialog(
        title: const Text('Add Project', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff374151),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: costController,
                decoration: InputDecoration(
                  labelText: 'Cost',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Handle image upload and add to imageUrls
                },
                child: const Text('Upload Image'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              // Handle adding the project
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProject(String projectId) async {
    final GetStorage _storage = GetStorage();
    final token = _storage.read('token');
    final url = '${AppConfig.baseUrl}/api/Projects/$projectId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _fetchProjects(); // Refresh the list
        Get.snackbar('Success', 'Project deleted successfully');
      } else {
        throw Exception('Failed to delete project');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete project: $e');
    }
  }

  void _showEditProjectDialog(Map<String, dynamic> project) {
    final TextEditingController nameController = TextEditingController(text: project['name']);
    final TextEditingController descriptionController = TextEditingController(text: project['description']);
    final TextEditingController costController = TextEditingController(text: project['cost'].toString());
    List<String> imageUrls = List.from(project['projectImageUrl']);

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Project', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff374151),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: costController,
                decoration: InputDecoration(
                  labelText: 'Cost',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Handle image upload and add to imageUrls
                  final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    final imageUrl = await _uploadImage(File(image.path));
                    if (imageUrl != null) {
                      setState(() {
                        imageUrls.add(imageUrl);
                      });
                    }
                  }
                },
                child: const Text('Upload Image'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Project Images:',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                height: 100,
                width: 300,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Image.network(
                            imageUrls[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  imageUrls.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              final updatedProject = {
                "name": nameController.text,
                "description": descriptionController.text,
                "cost": double.parse(costController.text),
                "projectImageUrl": imageUrls,
              };

              final token = _storage.read('token');
              final url = '${AppConfig.baseUrl}/api/Projects/${project['id']}';

              try {
                final response = await http.put(
                  Uri.parse(url),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode(updatedProject),
                );

                if (response.statusCode == 200) {
                  _fetchProjects(); // Refresh the list
                  Get.back();
                  Get.snackbar('Success', 'Project updated successfully');
                } else {
                  throw Exception('Failed to update project');
                }
              } catch (e) {
                Get.snackbar('Error', 'Failed to update project: $e');
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff2d3649),
        onPressed: _showAddProjectDialog,
        child: const Icon(Icons.add, size: 39),
      ),
      body: Container(
        margin: const EdgeInsets.all(16), // Add margin for better spacing
        padding: const EdgeInsets.all(16), // Add padding for better spacing
        decoration: BoxDecoration(
          color: const Color(0xff374151), // Background color for the container
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        child: ListView.builder(
          itemCount: _projects.length,
          itemBuilder: (context, index) {
            final project = _projects[index];
            final imageUrl = project['projectImageUrl'] != null &&
                project['projectImageUrl'].isNotEmpty
                ? project['projectImageUrl'][0]
                : null;

            return Card(
              color: const Color(0xff2d3649),
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: imageUrl != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 70,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(Icons.image, size: 50, color: Colors.white),
                title: Text(
                  project['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditProjectDialog(project),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProject(project['id']),
                    ),
                  ],
                ),
                onTap: () => _showProjectDetails(project),
              ),
            );
          },
        ),
      ),
    );
  }
}


