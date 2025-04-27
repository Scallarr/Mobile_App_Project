import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project/Login.dart';
import 'package:project/User/Bookasset_User.dart';
import 'package:project/User/Home_User.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart'; // Add this import for JWT decoding

class HistoryUser extends StatefulWidget {
  final File? profileImage;

  const HistoryUser({Key? key, this.profileImage}) : super(key: key);

  @override
  State<HistoryUser> createState() => _HistoryUser();
}

class _HistoryUser extends State<HistoryUser> {
  List<dynamic> books = [];

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        _showSessionExpiredDialog();
        return;
      }

      // Decode JWT and get the payload
      final jwt = JWT.decode(token!);
      final payload = jwt.payload;

      // Check for `exp` and `userId` in payload
      final exp = payload['exp'];
      final userId = payload['userId'];
      if (exp == null || userId == null) {
        _showSessionExpiredDialog();
        return;
      }

      // Check token expiration
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (exp <= currentTime) {
        _showSessionExpiredDialog();
        return;
      }
      print("Token: $token");

      print("User ID from payload: $userId");

      //=================เปลี่ยน ip=========================================
      final response = await http.get(
        Uri.parse('http://10.0.1.239:3000/user/history'),
        headers: {
          'Authorization': ' $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          books = json.decode(response.body);

          // ทำให้pending ขึ้นก่อน
          books.sort((a, b) {
            if (a['status'] == 'pending' && b['status'] != 'pending') {
              return -1;
            } else if (b['status'] == 'pending' && a['status'] != 'pending') {
              return 1; //
            }
            return 0; //
          });
        });
      } else if (response.statusCode == 401) {
        print("Unauthorized: ${response.body}");
        _showSessionExpiredDialog();
      } else {
        // Handle other errors
        print("Error: ${response.statusCode}");
        throw Exception('Failed to load history');
      }
    } catch (e) {
      print('Error: $e');
      _showSessionExpiredDialog();
    }
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text("Session expired or invalid. Please log in again."),
        actions: <Widget>[
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildHistoryContent(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Image.asset(
              'Assets/image/video-player.png',
              width: 50,
              height: 35,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 30),
          const Text(
            'Movie Assets',
            style: TextStyle(
              fontFamily: 'PlayfairDisplay-ExtraBold',
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 30),
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
                      child: Image.file(
                        widget.profileImage!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.account_circle,
                      size: 40, color: Colors.white),
              backgroundColor: const Color.fromARGB(255, 118, 117, 117),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF4C8479),
    );
  }

  Widget _buildHistoryContent() {
    return SingleChildScrollView(
      child: Column(
        children: books.map((book) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.asset(
                      book['movie_picture'] ??
                          'Assets/image/default.jpg', // ให้เป็นค่า default ถ้า null
                      fit: BoxFit.cover,
                      height: 145,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          book['book_name'] ??
                              'No Title', // ถ้า null ใช้ค่า default
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Movie ID: ${book['movie_ID']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Borrowed: ${book['borrowed_date']}',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black87),
                        ),
                        Text(
                          'Returned: ${book['returned_date']}',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 7),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          book['status'] == 'approved'
                              ? Icons.check_circle
                              : book['status'] == 'returned'
                                  ? Icons.replay_circle_filled
                                  : book['status'] == 'pending'
                                      ? Icons.hourglass_top
                                      : Icons.cancel,
                          color: book['status'] == 'approved'
                              ? Colors.blue
                              : book['status'] == 'returned'
                                  ? const Color.fromARGB(255, 182, 18, 173)
                                  : book['status'] == 'pending'
                                      ? Colors.orange
                                      : Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          book['status']!,
                          style: TextStyle(
                            color: book['status'] == 'approved'
                                ? Colors.blue
                                : book['status'] == 'returned'
                                    ? const Color.fromARGB(255, 182, 18, 133)
                                    : book['status'] == 'pending'
                                        ? Colors.orange
                                        : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    int _selectedIndex = 2;
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
          icon: _buildIcon('Assets/image/history (1).png', 2),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon('Assets/image/logout.png', 3),
          label: 'Logout',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.black,
      showUnselectedLabels: true,
      onTap: (index) {
        setState(() {
          if (index == 3) {
            _showLogoutConfirmation();
            return;
          }
          _selectedIndex = index;
        });
        switch (index) {
          case 0:
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeUser()));
            break;
          case 1:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BookassetUser(profileImage: widget.profileImage)));
            break;
          case 2:
            break;
        }
      },
    );
  }

  Widget _buildIcon(String imagePath, int index) {
    int _selectedIndex = 2;
    return ColorFiltered(
      colorFilter: _selectedIndex == index
          ? ColorFilter.mode(
              const Color.fromARGB(255, 255, 255, 255), BlendMode.srcIn)
          : ColorFilter.mode(Colors.black, BlendMode.srcIn),
      child: Image.asset(
        imagePath,
        width: 25, // ปรับขนาดตามต้องการ
        height: 25,
      ),
    );
  }

  // Show logout confirmation dialog
// Show logout confirmation dialog
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
