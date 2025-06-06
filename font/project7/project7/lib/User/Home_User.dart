import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project/Login.dart';

import 'dart:io';
import 'package:project/User/Bookasset_User.dart';
import 'package:project/User/History_User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({super.key});

  @override
  State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  static File? _imageUser;
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'image': 'Assets/image/all.png'},
    {
      'name': 'Drama',
      'image': 'Assets/image/drama.png',
    },
    {
      'name': 'Comedy',
      'image': 'Assets/image/comedy.png',
    },
    {
      'name': 'Thriller',
      'image': 'Assets/image/thriller.png',
    },
    {
      'name': 'Crime',
      'image': 'Assets/image/crime.png',
    },
    {
      'name': 'Fantasy',
      'image': 'Assets/image/fantasy.png',
    },
    {
      'name': 'History',
      'image': 'Assets/image/history.png',
    },
    {
      'name': 'Romantic',
      'image': 'Assets/image/romance.png',
    },
    {
      'name': 'Action',
      'image': 'Assets/image/action.png',
    },
  ];

  final List<String> imgList = [
    'Assets/image/Recommend_5.jpg',
    'Assets/image/Recommend_2.jpg',
    'Assets/image/Recommend_4.jpg',
    'Assets/image/Recommend_3.jpg',
  ];

  final List<String> imgTitles = [
    'BATMAN ',
    'AVENGERS ENDGAME',
    'BLACH PANTHER',
    'THE FLASH',
  ];

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _imageUser = File(result.files.single.path!);
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      _showLogoutConfirmation(); // แสดงการยืนยันล็อกเอาท์เมื่อเลือกไอคอนล็อกเอาท์
      return;
    }
    Widget page;
    switch (index) {
      case 1:
        page = BookassetUser(profileImage: _imageUser);
        break;
      // case 2:
      //   page = StatusUser(profileImage: _imageUser);
      //   break;
      case 2:
        page = HistoryUser(profileImage: _imageUser);
        break;
      case 3:
        page = HistoryUser(profileImage: _imageUser);
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _navigateToCategory(int index) {
    String selectedCategory = categories[index]['name'];

    // ตรวจสอบว่าคุณสามารถเรียกหน้าใหม่ได้อย่างถูกต้อง
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BookassetUser(
          profileImage: _imageUser,
          category: selectedCategory,
        ),
      ),
    );
  }

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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Image.asset(
              'Assets/image/video-player.png',
              width: 50,
              height: 35,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 40),
          const Text('Welcome!',
              style: TextStyle(
                  fontFamily: 'PlayfairDisplay-ExtraBold',
                  color: Colors.white,
                  fontSize: 33,
                  fontWeight: FontWeight.w400)),
          const SizedBox(width: 40),
          Expanded(
            child: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                child: _imageUser != null
                    ? ClipOval(
                        child: Image.file(_imageUser!,
                            width: 45, height: 40, fit: BoxFit.cover),
                      )
                    : const Icon(Icons.account_circle,
                        size: 43.5, color: Colors.white),
                backgroundColor: const Color.fromARGB(255, 118, 117, 117),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF4C8479),
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
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Categories',
                    style: TextStyle(
                        fontFamily: 'PlayfairDisplay-ExtraBold',
                        fontSize: 23,
                        fontWeight: FontWeight.w500)),
                const SizedBox(width: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookassetUser(
                              profileImage: _imageUser,
                              category: 'All',
                            ), // Replace with your page
                          ),
                        );
                      },
                      child: const Opacity(
                        opacity: 0.85,
                        child: Text(
                          'See all Movies',
                          style: TextStyle(
                            fontFamily: 'PlayfairDisplay-ExtraBold',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 0), // Add some spacing
                    GestureDetector(
                      onTap: () {
                        // Add your navigation action here
                        // For example:
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookassetUser(
                              profileImage: _imageUser,
                              category: 'All',
                            ), // Replace with your page
                          ),
                        );
                      },
                      child: const Opacity(
                        opacity: 0.85,
                        child: Icon(Icons.skip_next),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 3),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _navigateToCategory(index),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(0.8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 244, 239, 239),
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(197, 0, 0, 0)
                                    .withOpacity(0.80),
                                offset: const Offset(5, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 63,
                              height: 61,
                              child: Center(
                                child: Image.asset(
                                  categories[index]['image'],
                                  fit: BoxFit.contain,
                                  width: 60,
                                  height: 48,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Opacity(
                          opacity: 0.65,
                          child: Text(
                            categories[index]['name'],
                            style: const TextStyle(
                              fontFamily: 'PTserif-regular',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(width: 1),
                Text('Recommend',
                    style: TextStyle(
                        fontFamily: 'PlayfairDisplay-ExtraBold',
                        fontSize: 22,
                        fontWeight: FontWeight.w500)),
                SizedBox(width: 2),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookassetUser(
                              profileImage: _imageUser,
                              category: 'All',
                            ), // Replace with your page
                          ),
                        );
                      },
                      child: const Opacity(
                        opacity: 0.85,
                        child: Text(
                          'See all Movies',
                          style: TextStyle(
                            fontFamily: 'PlayfairDisplay-ExtraBold',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 1), // Add some spacing
                    GestureDetector(
                      onTap: () {
                        // Add your navigation action here
                        // For example:
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookassetUser(
                              profileImage: _imageUser,
                              category: 'All',
                            ), // Replace with your page
                          ),
                        );
                      },
                      child: const Opacity(
                        opacity: 0.85,
                        child: Icon(Icons.skip_next),
                      ),
                    ),
                    const SizedBox(width: 13),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 140,
              width: 600,
              child: CarouselSlider(
                items: imgList.asMap().entries.map((entry) {
                  String imgUrl = entry.value;

                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                          image: DecorationImage(
                            image: imgUrl.startsWith('http')
                                ? NetworkImage(imgUrl)
                                : AssetImage(imgUrl) as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          // child: Text(
                          //   imgTitles[index],
                          //   style: const TextStyle(
                          //     fontFamily: 'Kanit',
                          //     color: Color.fromARGB(255, 231, 231, 231),
                          //     fontSize: 16,
                          //   ),
                          // ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  viewportFraction: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF4C8479),
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: _buildIcon('Assets/image/home.png', 0), // เปลี่ยนเป็นรูป home
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon('Assets/image/asset.png', 1), // เปลี่ยนเป็นรูป book
          label: 'Assets',
        ),
        // BottomNavigationBarItem(
        //   icon:
        //       _buildIcon('Assets/image/status.png', 2), // เปลี่ยนเป็นรูป status
        //   label: 'Status',
        // ),
        BottomNavigationBarItem(
          icon: _buildIcon(
              'Assets/image/history (1).png', 2), // เปลี่ยนเป็นรูป history
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon:
              _buildIcon('Assets/image/logout.png', 3), // เปลี่ยนเป็นรูป logout
          label: 'Log out',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.black,
      showUnselectedLabels: true,
      onTap: _onItemTapped,
    );
  }

  Widget _buildIcon(String imagePath, int index) {
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
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
