import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:project/Approver/Assets_Approver.dart';
import 'package:project/Approver/Dashboard_Approver.dart';
import 'package:project/Approver/History_Approver.dart';
import 'package:project/Approver/Home_Approver.dart';
import 'package:project/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class RequestApprover extends StatefulWidget {
  final File? profileImage;

  const RequestApprover({super.key, this.profileImage});

  @override
  State<RequestApprover> createState() => _RequestApproverState();
}

class _RequestApproverState extends State<RequestApprover> {
  int _selectedIndex = 2;
  String searchQuery = '';
  List<dynamic> filteredList = [];
  bool isLoading = true;

  get borrowId => null;

  @override
  void initState() {
    super.initState();
    fetchFilteredList(); // Fetch assets
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

  Future<void> fetchFilteredList() async {
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

      // แสดงค่า token สำหรับการดีบัก
      print("Token: $token");

      final response = await http.get(
        Uri.parse('http://10.0.1.239:3000/approver/confirm'),
        headers: {
          'Authorization': ' $token',
          'Content-Type': 'application/json',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          filteredList =
              List<Map<String, dynamic>>.from(jsonDecode(response.body));
          print(filteredList);
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

  Future<String> _handleRequest(int borrowId, bool isApprove) async {
    final status = isApprove ? 'approved' : 'rejected';

    print('Using borrowId: $borrowId');

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      final response = await http.post(
        Uri.parse(
            'http://10.0.1.239:3000/approver/confirm/$borrowId'), // ใช้ borrowId
        body: json.encode({'borrowId': borrowId, 'status': status}),
        headers: {
          'Authorization': ' $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response Data: $responseData'); // เพิ่ม debug
        return responseData['status']; // ตรวจสอบว่าเซิร์ฟเวอร์ส่งค่ากลับถูกต้อง
      } else {
        print('Error Code: ${response.statusCode}, Body: ${response.body}');
        return 'error';
      }
    } catch (e) {
      print('Error: $e');
      return 'error';
    }
  }

  @override
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA9C7C3), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(),
            // buildSearchBar(), // Moved search bar above the body
            Expanded(child: _buildBody()),
          ],
        ),
      ),
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
            'Requests',
            style: TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w500,
            ),
          ),
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
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(226, 0, 0, 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (query) {
          setState(() {
            searchQuery = query;
          });
        },
        decoration: InputDecoration(
          labelText: 'Search',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Container _buildBody() {
    // Filter the list based on the search query
    var request = filteredList.where((item) {
      // Ensure item['movie_name'] is not null and is converted to lowercase for case-insensitive search
      String movieName =
          item['movie_name'] ?? ''; // Fallback to an empty string if null
      return movieName.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    // Return a container widget with the filtered request
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: request.length,
        itemBuilder: (context, index) {
          // Replace with your movie card widget
          return _buildMovieCard(index, request);
        },
      ),
    );
  }

  Widget _buildMovieCard(int index, List filteredList) {
    // Safely access values with fallback default values if null
    String moviePic = filteredList[index]['movie_pic'] ??
        'assets/default_image.png'; // Default image
    String movieName = filteredList[index]['movie_name'] ?? 'Unknown Movie';
    int movieId = filteredList[index]['movie_id']; // Default value as int
    String borrowedDate =
        filteredList[index]['borrowed_date'] ?? 'Not borrowed';
    String returnedDate =
        filteredList[index]['returned_date'] ?? 'Not returned';
    String borrowerName =
        filteredList[index]['borrower_name'] ?? 'Unknown Borrower';
    String status = (filteredList[index]['status'] as String?) ?? 'pending';

    // Format dates
    DateTime borrowedDateTime =
        DateTime.tryParse(borrowedDate) ?? DateTime.now();
    DateTime returnedDateTime =
        DateTime.tryParse(returnedDate) ?? DateTime.now();
    String formattedBorrowedDate =
        DateFormat('yy/MM/dd').format(borrowedDateTime);
    String formattedReturnedDate =
        DateFormat('yy/MM/dd').format(returnedDateTime);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 247, 247, 247),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(197, 0, 0, 0).withOpacity(0.80),
            offset: const Offset(5, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                // Image widget
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Image.asset(
                    moviePic, // Safely use the moviePic
                    height: 160,
                    width: 120, // Set a fixed size for the image
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 25),
                // Wrap the Column with Expanded to allow the text content to take remaining space
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movieName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: $movieId',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Borrowed: $formattedBorrowedDate',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Returned: $formattedReturnedDate',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Borrower: $borrowerName',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Status: $status',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue, // Always blue text color
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Approve Button
                Container(
                  width: 120, // Fixed width for both buttons
                  height: 40, // Fixed height for both buttons
                  decoration: BoxDecoration(
                    color:
                        const Color.fromARGB(255, 2, 82, 180), // Button color
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25), // Shadow color
                        offset: const Offset(2, 2), // Shadow position
                        blurRadius: 6, // Shadow blur
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _showApprovalDialog(index, true),
                    style: ElevatedButton.styleFrom(
                      elevation: 0, // Remove internal shadow
                      backgroundColor: Colors.transparent, // Use parent's color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Approve',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
                // Reject Button
                Container(
                  width: 120,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        offset: const Offset(2, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _showApprovalDialog(index, false),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Reject',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

//approved or rejected
  void _showApprovalDialog(int index, bool isApprove) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(
              isApprove ? Icons.check_circle : Icons.cancel,
              color: isApprove ? Colors.green : Colors.red,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              isApprove ? 'Approve Movie' : 'Reject Movie',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            'Are you sure you want to ${isApprove ? "approve" : "reject"} this movie?',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 5, 5, 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // ดึง borrowId จาก filteredList
              final borrowId = filteredList[index]['borrow_id'];
              final response = await _handleRequest(borrowId, isApprove);

              setState(() {
                filteredList.removeAt(index); // ลบรายการที่ถูกยืนยันจากรายการ
              });
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(' Update Booking status success ')),
              );
            },
            child: Text(
              isApprove ? 'Approve' : 'Reject',
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove
                  ? const Color.fromARGB(255, 70, 3, 255)
                  : Colors.red,
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

  // Future<String> _handleRequest(int movieId, bool isApprove) async {
  //   // ส่งคำขอไปยังเซิร์ฟเวอร์ที่ใช้ API
  //   final status = isApprove ? 'approved' : 'rejected';

  //   try {
  //     final response = await http.post(
  //       Uri.parse(
  //           'https://192.168.1.6:3000/approver/confirm/$borrowId'), // URL ของ API ที่ใช้
  //       body: json.encode({'movieId': movieId, 'status': status}),
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     if (response.statusCode == 200) {
  //       // ตรวจสอบการตอบกลับจากเซิร์ฟเวอร์
  //       final responseData = json.decode(response.body);
  //       return responseData[
  //           'status']; // ส่งกลับสถานะ 'approved' หรือ 'rejected'
  //     } else {
  //       return 'error';
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //     return 'error';
  //   }
  // }

  //approved or rejected

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
          icon: _buildIcon('Assets/image/Request.png', 2),
          label: 'Request',
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
                MaterialPageRoute(builder: (context) => const HomeApprover()));
            break;
          case 1:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BookassetApprover(profileImage: widget.profileImage)));
            break;
          case 3:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        DashboardApprover(profileImage: widget.profileImage)));
            break;
          case 4:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HistoryApprover(profileImage: widget.profileImage)));
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
}
