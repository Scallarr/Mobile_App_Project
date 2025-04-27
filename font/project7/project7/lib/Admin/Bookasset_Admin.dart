import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project/Admin/Dashboard_Admin.dart';
import 'package:project/Admin/History_Admin.dart';
import 'package:project/Admin/Home_Admin.dart';
import 'package:project/Admin/Return_Admin.dart';
import 'package:project/Approver/Dashboard_Approver.dart';
import 'package:project/Approver/History_Approver.dart';
import 'package:project/Approver/Home_Approver.dart';
import 'package:project/Approver/Request_approver.dart';
import 'package:project/User/History_User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:project/Login.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart'; // เพิ่มการ import ที่นี่
import 'package:project/User/Home_User.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http_parser/http_parser.dart'; // เพิ่มการ import ที่นี่

import 'dart:ui'; // Import for BackdropFilter

class BookassetAdmin extends StatefulWidget {
  final File? profileImage;
  final String? category;
  final String? categoryImage;

  const BookassetAdmin(
      {super.key, this.profileImage, this.category, this.categoryImage});

  @override
  State<BookassetAdmin> createState() => _BookassetpageState();
}

class _BookassetpageState extends State<BookassetAdmin> {
  int _selectedIndex = 1;
  String? category = 'all';
  List<dynamic> _assets = [];
  bool isLoading = true;
  final Map<String, String> categoryImages = {
    'All': 'Assets/image/all.png',
    'Drama': 'Assets/image/drama.png',
    'Comedy': 'Assets/image/comedy.png',
    'Crime': 'Assets/image/crime.png',
    'Thriller': 'Assets/image/thriller.png',
    'Fantasy': 'Assets/image/fantasy.png',
    'History': 'Assets/image/history.png',
    'Romantic': 'Assets/image/romance.png',
    'Action': 'Assets/image/action.png',
  };
  final Map<String, int> categoriesMap = {
    'Drama': 1,
    'Comedy': 2,
    'Thriller': 3,
    'Crime': 4,
    'Fantasy': 5,
    'History': 6,
    'Romantic': 7,
    'Action': 8,
  };

  @override
  void initState() {
    super.initState();
    category = widget.category ?? "All"; // Accept category from HomeUser
    fetchAssets(); // Fetch assets data from the server
  }

  Future<void> fetchAssets() async {
    setState(() {
      isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        _showErrorDialog('Error: User not logged in. Please log in again.');
        return;
      }

      final response = await http.get(
        Uri.parse('http://10.0.1.239:3000/admin/asset'),
        headers: {
          'Authorization': ' $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _assets = jsonDecode(response.body);
          print(_assets);
        });
      } else {
        _showErrorDialog('Error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Error fetching assets: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body:
          isLoading ? Center(child: CircularProgressIndicator()) : _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (widget.profileImage != null) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: Image.file(widget.profileImage!),
                  ),
                );
              }
            },
            child: CircleAvatar(
              backgroundColor: Colors.grey[700],
              child: widget.profileImage != null
                  ? ClipOval(
                      child: Image.file(widget.profileImage!,
                          width: 50, height: 50, fit: BoxFit.cover),
                    )
                  : const Icon(Icons.account_circle,
                      size: 40, color: Colors.white),
            ),
          ),
          const Text(
            'Movie Assets',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap:
                _showLogoutConfirmation, // เรียกฟังก์ชันเมื่อต้องการออกจากระบบ
            child: Image.asset(
              'Assets/image/logout.png',
              width: 50,
              height: 35,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF4C8479),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.logout,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Confirm Logout',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 16),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color.fromARGB(226, 0, 0, 0), // Adjust this color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Adjust this color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const HomeAdmin();
        break;

      case 2:
        page = ReturnAdmin(profileImage: widget.profileImage);
        break;
      case 3:
        page = DashboardAdmin(profileImage: widget.profileImage);
        break;
      case 4:
        page = HistoryAdmin(profileImage: widget.profileImage);
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => page));
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF4C8479),
        items: [
          _buildBottomNavItem('Assets/image/home.png', 'Home', 0),
          _buildBottomNavItem('Assets/image/asset.png', 'Assets', 1),
          _buildBottomNavItem('Assets/image/return.png', 'Return', 2),
          _buildBottomNavItem('Assets/image/Dashboard.png', 'Dashboard', 3),
          _buildBottomNavItem('Assets/image/history (1).png', 'History', 4),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        onTap: (index) {
          _handleNavigation(index);
        });
  }

  BottomNavigationBarItem _buildBottomNavItem(
      String iconPath, String label, int index) {
    return BottomNavigationBarItem(
      icon: _buildIcon(iconPath, index),
      label: label,
    );
  }

  Widget _buildIcon(String imagePath, int index) {
    return ColorFiltered(
      colorFilter: _selectedIndex == index
          ? ColorFilter.mode(Colors.white, BlendMode.srcIn)
          : ColorFilter.mode(Colors.black, BlendMode.srcIn),
      child: Image.asset(
        imagePath,
        width: 25,
        height: 25,
      ),
    );
  }

  Container _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFA9C7C3), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildDropdown(),
            const SizedBox(height: 20),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: _buildContentForCategory(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentForCategory() {
    if (category == 'All') {
      return _buildAssetListContent();
    } else {
      final filteredAssets =
          _assets.where((asset) => asset['category_name'] == category).toList();

      return filteredAssets.isNotEmpty
          ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.45,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredAssets.length,
              itemBuilder: (context, index) {
                final asset = filteredAssets[index];
                return AssetCard(
                  asset: asset,
                  onTap: () {
                    final currentStatus = asset['status_movie'];

                    // ตรวจสอบสถานะปัจจุบัน
                    if (currentStatus == 'available' ||
                        currentStatus == 'unavailable') {
                      // แสดง Alert ยืนยันการเปลี่ยนสถานะ
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Row(
                              children: [
                                const Icon(
                                  Icons.swap_horiz, // ไอคอนสำหรับเปลี่ยนสถานะ
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // กำหนดสีไอคอน
                                  size: 27, // ขนาดของไอคอน
                                ),
                                const SizedBox(
                                    width: 8), // ระยะห่างระหว่างไอคอนกับข้อความ
                                const Text('Change Status'),
                              ],
                            ),
                            content: Text(
                              'Are you sure to change $currentStatus to ${currentStatus == 'available' ? 'unavailable' : 'available'}?',
                            ),
                            actions: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // ปิด Dialog
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 0, 0, 0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // ปิด Dialog
                                      // ดำเนินการเปลี่ยนสถานะ
                                      _updateMovieStatus(
                                          asset['movie_id'], currentStatus,
                                          (newStatus) {
                                        setState(() {
                                          asset['status_movie'] =
                                              newStatus; // อัพเดตสถานะใหม่ใน asset
                                        });
                                        // แสดง Snackbar แจ้งเตือนสำเร็จ
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Status changed successfully to $newStatus.'),
                                            duration:
                                                const Duration(seconds: 2),
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 40, 41, 40),
                                          ),
                                        );
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                    ),
                                    child: const Text(
                                      'Confirm',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          );
                        },
                      );
                    } else {
                      // แสดง Alert ว่าไม่สามารถเปลี่ยนสถานะได้
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content: Text(
                                'Cannot change status "${currentStatus}".'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // ปิด Dialog
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  onEdit: () {
                    _showEditDialog(context, asset); // Show edit dialog
                  },
                );
              },
            )
          : Center(
              child: Text('Please Select Categorie',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
            );
    }
  }

  void _updateMovieStatus(int movieId, String currentStatus,
      Function(String) onStatusUpdated) async {
    // สร้าง mapping ของสถานะ
    final statusMap = {
      'available': 1, // "available" แปลงเป็น 1
      'unavailable': 2, // "unavailable" แปลงเป็น 2
    };

    // ตรวจสอบว่า currentStatus อยู่ใน statusMap หรือไม่
    if (statusMap.containsKey(currentStatus)) {
      final newStatus =
          currentStatus == 'available' ? 2 : 1; // กำหนดค่าที่จะส่งไปยัง API
      final url = 'http://10.0.1.239:3000/admin/assets/$movieId/disable';

      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('token');
        final response = await http.put(
          Uri.parse(url),
          headers: {
            'Authorization': ' $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'status_movie': newStatus}),
        );

        if (response.statusCode == 200) {
          print('Status updated successfully');
          // เปลี่ยนสถานะใหม่ใน callback
          onStatusUpdated(
              currentStatus == 'available' ? 'unavailable' : 'available');
        } else {
          print('Failed to update status: ${response.body}');
        }
      } catch (e) {
        print('Error updating status: $e');
      }
    } else {
      print('Invalid status: $currentStatus');
    }
  }

  Widget _buildAssetListContent() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.45,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _assets.length,
      itemBuilder: (context, index) {
        final asset = _assets[index];
        return AssetCard(
          asset: asset,
          onTap: () {
            final currentStatus = asset['status_movie'];

            // ตรวจสอบสถานะปัจจุบัน
            if (currentStatus == 'available' ||
                currentStatus == 'unavailable') {
              // แสดง Alert ยืนยันการเปลี่ยนสถานะ
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Row(
                      children: [
                        const Icon(
                          Icons.swap_horiz, // ไอคอนสำหรับเปลี่ยนสถานะ
                          color: Color.fromARGB(255, 0, 0, 0), // กำหนดสีไอคอน
                          size: 27, // ขนาดของไอคอน
                        ),
                        const SizedBox(
                            width: 8), // ระยะห่างระหว่างไอคอนกับข้อความ
                        const Text('Change Status'),
                      ],
                    ),
                    content: Text(
                        'Are you sure to change ${currentStatus} to ${currentStatus == 'available' ? 'unavailable' : 'available'}?'),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // ปิด Dialog
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 0, 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // ปิด Dialog
                              // ดำเนินการเปลี่ยนสถานะ
                              _updateMovieStatus(
                                  asset['movie_id'], currentStatus,
                                  (newStatus) {
                                setState(() {
                                  asset['status_movie'] =
                                      newStatus; // อัพเดตสถานะใหม่ใน asset
                                });
                                // แสดง Snackbar แจ้งเตือนสำเร็จ
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Status changed successfully to $newStatus.'),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor:
                                        const Color.fromARGB(255, 29, 28, 28),
                                  ),
                                );
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 244, 17, 17),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            child: const Text(
                              'Confirm',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    ],
                  );
                },
              );
            } else {
              // แสดง Alert ว่าไม่สามารถเปลี่ยนสถานะได้
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Error'),
                    content: Text('Cannot change status "${currentStatus}".'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // ปิด Dialog
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          },
          onEdit: () {
            _showEditDialog(context, asset); // Show edit dialog
          },
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> asset) {
    final _movieNameController =
        TextEditingController(text: asset['movie_name']);
    final _descriptionController =
        TextEditingController(text: asset['description']);
    String? selectedCategory = asset['category_name'];
    File? updatedImage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.edit_note, // ไอคอนสำหรับ Edit
                  color: Color.fromARGB(255, 0, 0, 0),
                  size: 30, // กำหนดสีของไอคอน
                ),
                SizedBox(width: 8), // ระยะห่างระหว่างไอคอนกับข้อความ
                Text('Edit Movie'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _movieNameController,
                  decoration: const InputDecoration(labelText: 'Movie Name'),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(
                  height: 15,
                ),
                DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  onChanged: (newValue) {
                    setState(() {
                      selectedCategory = newValue;
                    });
                  },
                  items: categoriesMap.keys.map((categoryName) {
                    return DropdownMenuItem<String>(
                      value: categoryName,
                      child: Text(categoryName),
                    );
                  }).toList(),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(type: FileType.image);
                    if (result != null) {
                      setState(() {
                        updatedImage = File(result.files.single.path!);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.black, // กำหนดสีพื้นหลังของปุ่มเป็นสีดำ
                  ),
                  child: const Text(
                    'Pick New Image',
                    style: TextStyle(
                      color: Colors.white, // กำหนดสีของข้อความในปุ่มเป็นสีขาว
                    ),
                  ),
                ),
                updatedImage != null
                    ? Text(
                        'Selected: ${updatedImage!.path.split('/').last}',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      )
                    : const Text('No image selected',
                        style: TextStyle(
                          color: Colors.red,
                        )),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 48, 10, 238),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedCategory != null &&
                          _movieNameController.text.isNotEmpty &&
                          _descriptionController.text.isNotEmpty &&
                          updatedImage != null) {
                        // ดำเนินการอัปเดตข้อมูลเมื่อข้อมูลครบถ้วน
                        print("Editing Movie with ID: ${asset['movie_id']}");
                        print("Movie Name: ${_movieNameController.text}");
                        print("Description: ${_descriptionController.text}");
                        print("Category: $selectedCategory");
                        print("Updated Image Path: ${updatedImage?.path}");

                        await _updateMovie(
                          asset['movie_id'],
                          _movieNameController.text,
                          _descriptionController.text,
                          categoriesMap[selectedCategory]!,
                          updatedImage,
                        );
                        fetchAssets(); // Refresh assets after update
                        Navigator.of(context).pop();
                      } else {
                        // แสดง Snackbar แจ้งเตือน
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('please Fill in all Fill '),
                            duration: Duration(seconds: 2),
                            backgroundColor: Color.fromARGB(255, 15, 15, 15),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 232, 17, 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateMovie(
    int movieId,
    String movieName,
    String description,
    int categoryId,
    File? file,
  ) async {
    try {
      // Create the URI for the update request
      final uri =
          Uri.parse('http://10.0.1.239:3000/admin/assets/$movieId/edit');

      // Create the multipart request
      final request = http.MultipartRequest('PUT', uri);

      // Create the body with the movie details
      final Map<String, dynamic> requestBody = {
        'movie_name': movieName,
        'description': description,
        'categorie': categoryId, // Category ID should be an integer
        'status_movie':
            1, // Assuming the status should be '1' (active or available)
      };

      // Add the JSON body to the request
      request.fields['data'] = jsonEncode(requestBody);

      // Add the image file if it's selected
      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'pic',
          file.path,
          contentType: MediaType('application', 'octet-stream'),
        ));
      }

      // Send the request
      final response = await request.send();

      // Check the response status and show appropriate feedback
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Movie updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error updating movie: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 20.0), // เพิ่ม padding รอบๆ container
          child: Container(
            width: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: DropdownButton<String>(
              value: category,
              onChanged: (String? newValue) {
                setState(() {
                  category = newValue;
                });
              },
              items: <String>[
                'All',
                'Drama',
                'Comedy',
                'Crime',
                'Thriller',
                'Fantasy',
                'History',
                'Romantic',
                'Action',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 10),
                      Image.asset(
                        categoryImages[value] ?? 'assets/images/default.png',
                        width: 24,
                        height: 24,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              hint: const Text('Select Category'),
              underline: Container(),
              isExpanded: true,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.add,
            size: 30, // ปรับขนาดไอคอน
          ),
          onPressed: _showAddMovieDialog,
        )
      ],
    );
  }

  void _showAddMovieDialog() {
    final _movieNameController = TextEditingController();
    final _descriptionController = TextEditingController();
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.library_add, // ไอคอนสำหรับการเพิ่ม
              color: Color.fromARGB(255, 0, 0, 27), // กำหนดสีไอคอน
              size: 24, // ขนาดของไอคอน
            ),
            const SizedBox(width: 8), // ระยะห่างระหว่างไอคอนกับข้อความ
            const Text('Add Movie'),
          ],
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _movieNameController,
                  decoration: const InputDecoration(labelText: 'Movie Name'),
                ),
                const SizedBox(
                  height: 5,
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(
                  height: 15,
                ),
                DropdownButton<String>(
                  value: selectedCategory,
                  hint: const Text('Select Category'),
                  isExpanded: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue;
                    });
                  },
                  items: categoriesMap.keys.map((String categoryName) {
                    return DropdownMenuItem<String>(
                      value: categoryName,
                      child: Text(categoryName),
                    );
                  }).toList(),
                ),
                const SizedBox(
                  height: 5,
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _pickFile(setState);
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                      foregroundColor: Colors.white // กำหนดสีข้อความเป็นสีฟ้า
                      ),
                  child: const Text('Pick a File'),
                ),
                _file == null
                    ? const Text(
                        'No file selected',
                        style: TextStyle(color: Colors.red),
                      )
                    : Text(
                        'Selected file: ${_file!.path.split('/').last}',
                        style: TextStyle(color: Colors.blue),
                      ),
              ],
            );
          },
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 49, 15, 242),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final movieName = _movieNameController.text;
                  final description = _descriptionController.text;

                  if (_file != null && selectedCategory != null) {
                    final categoryId = categoriesMap[selectedCategory]!;
                    bool success = await _addMovie(
                        movieName, description, categoryId.toString(), _file!);

                    if (success) {
                      Navigator.of(context).pop(); // ปิด dialog
                      fetchAssets(); // อัปเดตรายการ assets
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all fields'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 232, 17, 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _pickFile(StateSetter setState) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!);
        print('Selected file: ${_file!.path}');
      });
    } else {
      setState(() {
        _file = null;
        print('No file selected');
      });
    }
  }

// ฟังก์ชันเลือกไฟล์
  File? _file; // เก็บไฟล์ที่เลือก
  int _fileNumber = 1; // เก็บหมายเลขไฟล์ที่เลือก (เริ่มจาก 1)

  Future<bool> _addMovie(
      String movieName, String description, String category, File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.1.239:3000/admin/add'),
      );

      request.fields['movie_name'] = movieName;
      request.fields['description'] = description;
      request.fields['categorie'] = category;
      request.fields['status_movie'] = '1';

      request.files.add(await http.MultipartFile.fromPath(
        'pic',
        file.path,
        contentType: MediaType('application', 'octet-stream'),
      ));

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Movie added successfully')));
        return true; // เพิ่มข้อมูลสำเร็จ
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error adding movie')));
        return false; // เกิดข้อผิดพลาด
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
      return false; // เกิดข้อผิดพลาด
    }
  }
}

class AssetCard extends StatelessWidget {
  final Map<String, dynamic> asset;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const AssetCard({
    required this.asset,
    required this.onTap,
    required this.onEdit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  if (asset['pic'] != null && asset['pic']!.isNotEmpty)
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(18)),
                      child: Image.asset(
                        asset['pic']!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 80, // ขนาดของไอคอน
                            color: Colors.grey, // สีของไอคอน
                          ),
                        ),
                      ),
                    )
                  else
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(18)),
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 100, // ขนาดของไอคอน
                            color: Colors.grey, // สีของไอคอน
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        Icons.edit_note, // เปลี่ยนเป็นไอคอนใหม่
                        color: const Color.fromARGB(
                            255, 243, 217, 217), // เปลี่ยนสีเป็นสีที่ต้องการ
                        size: 40, // กำหนดขนาดของไอคอน
                      ),
                      onPressed: onEdit,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      asset['movie_name'] ?? 'Title',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark, // ไอคอน Bookmark
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Movie ID: ${asset['movie_id']?.toString() ?? '0'}', // เชื่อมข้อความและแปลง movie_id เป็น String
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildStatusButton(asset['status_movie'] ?? 'Unknown'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildStatusButton(String statusMessage) {
  Color statusColor;
  String statusText;

  switch (statusMessage.toLowerCase()) {
    case 'available':
      statusColor = Colors.green;
      statusText = 'Available';
      break;
    case 'borrowed':
      statusColor = Colors.blueGrey;
      statusText = 'Borrowed';
      break;
    case 'unavailable':
      statusColor = Colors.red;
      statusText = 'Disabled';
      break;
    case 'pending':
      statusColor = Colors.orange;
      statusText = 'Pending';
      break;
    default:
      statusColor = Colors.grey;
      statusText = 'Unknown';
  }

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: statusColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: statusColor),
    ),
    child: Text(
      statusText,
      style: TextStyle(
        color: statusColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
