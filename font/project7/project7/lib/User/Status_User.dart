import 'package:flutter/material.dart';
import 'package:project/Login.dart';
import 'dart:io';

class StatusUser extends StatelessWidget {
  final File? profileImage;

  // ข้อมูลของหนังที่จะแสดง
  final String title = 'AVENGER ENDGAME';
  final String ID = 'C00020';
  // หรือ 'new'
  final String borrowedDate = '16/10/2024';
  final String returnedDate = '25/10/2024';
  final String status = 'approve';

  // เส้นทางของรูปหนัง (แทนที่ด้วยเส้นทางที่ถูกต้อง)
  final String movieImagePath = 'Assets/image/Recommend_2.jpg';

  const StatusUser({super.key, this.profileImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Image.asset(
              'Assets/image/video-player.png',
              width: 50,
              height: 35,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 60),
          const Text(
            'Status',
            style: TextStyle(
              fontFamily: 'PlayfairDisplay-ExtraBold',
              color: Colors.white,
              fontSize: 33,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 60),
          GestureDetector(
            onTap: () {
              if (profileImage != null) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: Image.file(profileImage!),
                  ),
                );
              }
            },
            child: CircleAvatar(
              child: profileImage != null
                  ? ClipOval(
                      child: Image.file(profileImage!,
                          width: 40, height: 40, fit: BoxFit.cover),
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

  Widget _buildBody() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(0.0), // เพิ่ม padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แสดงรูปหนัง
            Image.asset(
              movieImagePath,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black, // สีข้อความ
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${status.toUpperCase()}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500, // เพิ่มน้ำหนักให้ข้อความ
                color: status == 'approve' ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 12), // เพิ่มระยะห่าง
            Text(
              'Borrowed Date: $borrowedDate',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey, // เปลี่ยนสีข้อความให้ดูนุ่มนวล
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Returned Date: $returnedDate',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(BuildContext context) {
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
          icon: _buildIcon('Assets/image/status.png', 2),
          label: 'Status',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon('Assets/image/history (1).png', 3),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon('Assets/image/logout.png', 4),
          label: 'Log out',
        ),
      ],
      currentIndex: 2,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.black,
      showUnselectedLabels: true,
      onTap: (index) {
        if (index == 4) {
          _showLogoutConfirmation(context);
          return;
        }
        // นำทางไปยังหน้าต่างๆ ตามที่เลือก
      },
    );
  }

  Widget _buildIcon(String imagePath, int index) {
    return Image.asset(
      imagePath,
      width: 25,
      height: 25,
      color: index == 2 ? Colors.white : Colors.black,
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
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
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(226, 0, 0, 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
            ),
          ),
        ],
      ),
    );
  }
}
