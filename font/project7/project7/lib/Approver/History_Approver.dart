import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:project/Approver/Assets_Approver.dart';
import 'package:project/Approver/Dashboard_Approver.dart';
import 'package:project/Approver/Home_Approver.dart';
import 'package:project/Approver/Request_approver.dart';
import 'package:project/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryApprover extends StatefulWidget {
  final File? profileImage;

  const HistoryApprover({super.key, this.profileImage});

  @override
  State<HistoryApprover> createState() => _StatuspageState();
}

class _StatuspageState extends State<HistoryApprover> {
  int _selectedIndex = 4; // Set the current page index
  List<dynamic> books = []; // To hold the fetched data

  @override
  void initState() {
    super.initState();
    _fetchHistory(); // Fetch the history when the widget is initialized
  }

  // Fetch borrowing history from the server
  Future<void> _fetchHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      // Replace with actual approver ID
      final response = await http.get(
        Uri.parse('http://10.0.1.239:3000/approver/history'),
        headers: {
          'Authorization': ' $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          books = data.map((item) {
            return {
              'image': item['movie_picture'] ??
                  '', // Default to empty string if not available
              'title': item['book_name'] ?? '',
              'id': item['movie_ID'].toString(),
              'borrowedDate': item['borrowed_date'] ?? '',
              'returnedDate': item['returned_date'] ?? '',
              'bookingName': item['borrower_Named'] ?? '',
              'status': item['status'] ?? '',
            };
          }).toList();
        });
      } else {
        // Handle error if the request fails
        print('Failed to fetch history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // เปลี่ยนเป็นสีขาว
        ),
        child: _buildHistoryContent(),
      ),
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
          const SizedBox(width: 70),
          const Text(
            'History',
            style: TextStyle(
              fontFamily: 'PlayfairDisplay-ExtraBold',
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 70),
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
        title: const Row(
          children: [
            Icon(
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
        content: const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
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

  Widget _buildHistoryContent() {
    // Check if the books list is empty
    if (books.isEmpty) {
      return const Center(
        child: Text(
          'No history available', // Message for empty data
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      );
    }

    // If there is data, display the history content
    return SingleChildScrollView(
      child: Column(
        children: books.map((book) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Card(
              elevation: 4, // Add elevation for a floating effect
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // More rounded corners
              ),
              color: Colors.white, // Background color for the card
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(15)), // Round only the top corners
                    child: Image.asset(
                      book['image']!,
                      fit: BoxFit.cover,
                      height: 145,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15), // Consistent horizontal padding
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          book['title']!,
                          style: const TextStyle(
                            fontSize: 18, // Increased font size
                            fontWeight: FontWeight.bold,
                            color: Colors.black87, // Softer black color
                          ),
                        ),
                        Text(
                          'Book ID: ${book['id']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color:
                                Colors.black, // Softer color for secondary text
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
                          'Borrowed: ${book['borrowedDate']}',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black87),
                        ),
                        Text(
                          'Returned: ${book['returnedDate']}',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black87),
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
                          'Borrower: ${book['bookingName']}',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black87),
                        ),
                        Row(
                          children: [
                            Icon(
                              book['status'] == 'approved'
                                  ? Icons.check_circle
                                  : (book['status'] == 'rejected'
                                      ? Icons.cancel
                                      : Icons
                                          .loop), // Fallback to 'loop' icon for unknown status
                              color: book['status'] == 'approved'
                                  ? Colors.blue
                                  : (book['status'] == 'rejected'
                                      ? Colors.red
                                      : Colors
                                          .purple), // Purple for unknown status
                              size: 24,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              book['status']!,
                              style: TextStyle(
                                color: book['status'] == 'approved'
                                    ? Colors.blue
                                    : (book['status'] == 'rejected'
                                        ? Colors.red
                                        : Colors
                                            .purple), // Purple for unknown status
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10), // Extra space at the bottom
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
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
          case 2:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        RequestApprover(profileImage: widget.profileImage)));
            break;
          case 3:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        DashboardApprover(profileImage: widget.profileImage)));
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
