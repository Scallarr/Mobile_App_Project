import 'package:flutter/material.dart';
import 'package:project/Admin/Bookasset_Admin.dart';
import 'package:project/Admin/Dashboard_Admin.dart';
import 'package:project/Admin/History_Admin.dart';
import 'package:project/Admin/Home_Admin.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:project/Login.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReturnAdmin extends StatefulWidget {
  final File? profileImage;

  const ReturnAdmin({super.key, this.profileImage});

  @override
  State<ReturnAdmin> createState() => _StatuspageState();
}

class _StatuspageState extends State<ReturnAdmin> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
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
            'Return Assets',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
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
            child: const Text('Cancel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
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
            child: const Text('Logout'),
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

  Future<List<dynamic>> fetchReturnData() async {
    final response =
        await http.get(Uri.parse('http://10.0.1.239:3000/admin/return'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load return data');
    }
  }

  Container _buildBody() {
    return Container(
      child: FutureBuilder<List<dynamic>>(
        future: fetchReturnData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return _buildMovieCard(snapshot.data![index]);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildMovieCard(Map<String, dynamic> movieData) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Image.asset(
                movieData['movie_image'] ??
                    'https://via.placeholder.com/120x170',
                height: 200,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movieData['movie_name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('ID: ${movieData['movie_id']}'),
                  Text('Borrowed: ${movieData['borrowed_date']}'),
                  Text('Returned: ${movieData['returned_date']}'),
                  Text('Borrower: ${movieData['borrower_name']}'),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _returnAsset(movieData['borrow_id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 234, 61, 26),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 4),
                      minimumSize: const Size(160, 30),
                    ),
                    icon: const Icon(
                      Icons.assignment_returned,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text('Return Assets',
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _returnAsset(int borrowId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.assignment_returned,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Confirm Return',
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
            'Are you sure you want to return this asset?',
            style: TextStyle(fontSize: 16),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(), // Close the dialog
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Cancel',
                style: TextStyle(
                  color: Colors.white,
                )),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog
              try {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? token = prefs.getString('token');
                final response = await http.post(
                  Uri.parse('http://10.0.1.239:3000/admin/return/$borrowId'),
                  headers: {
                    'Authorization': ' $token',
                    'Content-Type': 'application/json',
                  },
                  body: json.encode({
                    'borrowId': borrowId,
                    'adminId': 'YOUR_ADMIN_ID', // Adjust adminId here
                  }),
                );

                if (response.statusCode == 200) {
                  setState(() {
                    // Refresh the data
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Asset returned successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Failed to return asset: ${response.body}')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('An error occurred: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Return',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
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
          case 3:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        DashboardAdmin(profileImage: widget.profileImage)));
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
}
