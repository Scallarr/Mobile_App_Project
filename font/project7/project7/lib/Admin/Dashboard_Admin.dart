import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:project/Admin/Bookasset_Admin.dart';
import 'package:project/Admin/History_Admin.dart';
import 'package:project/Admin/Home_Admin.dart';
import 'package:project/Admin/Return_Admin.dart';

import 'package:project/Approver/Assets_Approver.dart';
import 'package:project/Approver/History_Approver.dart';
import 'package:project/Approver/Home_Approver.dart';
import 'package:project/Approver/Request_approver.dart';
import 'package:project/Login.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart'; // Add this import for JWT decoding

class DashboardAdmin extends StatefulWidget {
  final File? profileImage;

  const DashboardAdmin({super.key, this.profileImage});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  int _selectedIndex = 3; // Set the current page index
  List<dynamic> statusData = []; // เก็บข้อมูลที่ได้จาก API
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData(); // เรียกใช้ API เมื่อเริ่มต้น
  }

  Future<void> _fetchData() async {
    const String url =
        "http://10.0.1.239:3000/approver/dashboard"; // แก้ไข URL ให้ตรงกับ API ของคุณ
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token =
          prefs.getString('token'); // ดึง token จาก SharedPreferences

      if (token == null) {
        throw Exception("Token is missing");
      }

      // เพิ่ม headers ในการร้องขอ
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': ' $token', // ใส่ Bearer Token
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        // ตรวจสอบรูปแบบ JSON
        if (decodedData is Map<String, dynamic> &&
            decodedData.containsKey('statusCounts')) {
          setState(() {
            statusData = decodedData['statusCounts'];
            print("Fetched data: $statusData");
            isLoading = false;
          });
        } else {
          throw Exception('Unexpected JSON format');
        }
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: isLoading ? _buildLoading() : _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              child: widget.profileImage != null
                  ? ClipOval(
                      child: Image.file(widget.profileImage!,
                          width: 43, height: 40, fit: BoxFit.cover),
                    )
                  : const Icon(Icons.account_circle,
                      size: 40, color: Colors.white),
              backgroundColor: const Color.fromARGB(255, 118, 117, 117),
            ),
          ),
          const SizedBox(width: 30),
          const Text(
            'Dashboard',
            style: TextStyle(
              fontFamily: 'PlayfairDisplay-ExtraBold',
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 30),
          GestureDetector(
            onTap: _showLogoutConfirmation,
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

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
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
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildCategorySelector(),
          const SizedBox(height: 60),
          _buildStatusCards(),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      width: 330,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(4, 6),
            blurRadius: 4,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'All',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatusCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: statusData.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final item = statusData[index];
          return _buildStatusCard(item['status_name'], item['total'].toString(),
              item['total_rooms'], _getStatusColor(item['status_name']));
        },
      ),
    );
  }

  Widget _buildStatusCard(
      String status, String count, int totalroom, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromARGB(255, 241, 239, 239),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                status,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$count/$totalroom ',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.teal;
      case 'borrowed':
        return Colors.purpleAccent;
      case 'unavailable':
        return Colors.redAccent;
      case 'pending':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF4C8479),
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: _buildIcon('Assets/image/home.png', 0),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon('Assets/image/asset.png', 1),
          label: 'Assets',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon('Assets/image/return.png', 2),
          label: 'Return',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon('Assets/image/Dashboard.png', 3),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon('Assets/image/history (1).png', 4),
          label: 'History',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.black,
      showUnselectedLabels: true,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomeAdmin()));
            break;
          case 1:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BookassetAdmin(profileImage: widget.profileImage)));
            break;
          case 2:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ReturnAdmin(profileImage: widget.profileImage)));
            break;
          case 4:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HistoryAdmin(profileImage: widget.profileImage)));
            break;
        }
      },
    );
  }

  Widget _buildIcon(String imagePath, int index) {
    return ColorFiltered(
      colorFilter: _selectedIndex == index
          ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
          : const ColorFilter.mode(Colors.black, BlendMode.srcIn),
      child: Image.asset(
        imagePath,
        width: 25,
        height: 25,
      ),
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
}
