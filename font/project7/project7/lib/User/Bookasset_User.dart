import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project/User/History_User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:project/Login.dart';
import 'dart:convert';
import 'package:project/User/Home_User.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'dart:ui'; // Import for BackdropFilter

class BookassetUser extends StatefulWidget {
  final File? profileImage;
  final String? category;
  final String? categoryImage;

  const BookassetUser(
      {super.key, this.profileImage, this.category, this.categoryImage});

  @override
  State<BookassetUser> createState() => _BookassetpageState();
}

class _BookassetpageState extends State<BookassetUser> {
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

  @override
  void initState() {
    super.initState();
    category = widget.category ?? "All";
    fetchAssets(); // Fetch assets
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
      //=================เปลี่ยน ip=========================================
      final response = await http.get(
        Uri.parse('http://10.0.1.239:3000/user/assets'),
        headers: {
          'Authorization': ' $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _assets = jsonDecode(response.body);
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
                      child: Image.file(widget.profileImage!,
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
      print('Selected Category: $category');
      final filteredAssets =
          _assets.where((asset) => asset['category_name'] == category).toList();

      return filteredAssets.isNotEmpty
          ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.55, // ปรับสัดส่วนพื้นที่การ์ด
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredAssets.length,
              itemBuilder: (context, index) {
                final asset = filteredAssets[index];
                return AssetCard(
                    asset: asset,
                    onTap: () {
                      print('Status movie: ${asset['status_movie']}');
                      if (asset['status_movie'] == 1) {
                        // ตรวจสอบค่าเป็น int แทน
                        _showAvailablePopup(asset['movie_name'] ?? '',
                            asset['movie_id'] ?? '', asset['pic'] ?? '');
                      } else {
                        _showErrorDialog('This asset is not available');
                      }
                    });
              },
            )
          : Center(
              child: Text('Please Select Categorie',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
            );
    }
  }

  Widget _buildAssetListContent() {
    const int availableStatus = 1;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.55,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _assets.length,
      itemBuilder: (context, index) {
        final asset = _assets[index];
        return AssetCard(
          asset: asset,
          onTap: () {
            if (asset['status_movie'] == availableStatus) {
              _showAvailablePopup(
                asset['movie_name'] ?? 'Unknown Movie',
                asset['movie_id'] ?? 'Unknown ID',
                asset['pic'] ?? 'assets/placeholder_image.png',
              );
            } else {
              _showErrorDialog('This asset is not available');
            }
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

  void _showAvailablePopup(String title, int id, String imagePath) {
    final DateTime now = DateTime.now();
    final String currentDate = "${now.day}/${now.month}/${now.year}";

    // สร้าง TextEditingController สำหรับ Borrow Date และ Returned Date
    TextEditingController borrowDateController =
        TextEditingController(text: currentDate); // วันที่ยืม ล็อกเป็นวันนี้
    TextEditingController returnedDateController =
        TextEditingController(text: currentDate); // วันที่คืน

    showDialog(
      context: context,
      builder: (context) => Stack(
        children: [
          // เบลอพื้นหลัง
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),

          Center(
            child: AlertDialog(
              title: const Center(child: Text('Booking Form ')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 2),
                      ),
                      child: Image.asset(
                        imagePath, //รูปที่เลือกจอง
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.broken_image, size: 150);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$title',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold, //
                      fontSize: 18, //
                    ),
                  ),

                  const SizedBox(height: 8),
                  // Borrow Date
                  TextField(
                    controller: borrowDateController,
                    decoration: InputDecoration(
                      labelText: 'Borrow Date',
                      labelStyle: const TextStyle(
                        color: Colors.black87,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.calendar_today,
                          color: Colors.black87,
                        ),
                        onPressed: () async {
                          // เปิด DatePicker เมื่อผู้ใช้คลิกที่ไอคอน
                          DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime
                                .now(), // วันที่เริ่มต้นเป็นวันที่ปัจจุบัน
                            firstDate:
                                DateTime(2000), // วันที่เริ่มต้นที่เลือกได้
                            lastDate:
                                DateTime(2101), // วันที่สุดท้ายที่เลือกได้
                          );

                          if (selectedDate != null) {
                            // ถ้าเลือกวันที่แล้ว ตั้งค่าให้ TextField
                            borrowDateController.text =
                                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                          }
                        },
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                    enabled: false, //เลือกวันไม่ได้
                  ),

                  // Returned Date
                  TextField(
                    controller: returnedDateController,
                    decoration: InputDecoration(
                      labelText: 'Returned Date',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          // เปิด DatePicker เมื่อผู้ใช้คลิกที่ไอคอน
                          DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime
                                .now(), // วันที่เริ่มต้นเป็นวันที่ปัจจุบัน
                            firstDate:
                                DateTime.now(), // วันที่เริ่มต้นที่เลือกได้
                            lastDate: DateTime(DateTime.now().year +
                                1), // วันที่สุดท้ายที่เลือกได้
                          );

                          if (selectedDate != null) {
                            // ถ้าเลือกวันที่แล้ว ตั้งค่าให้ returnedDateController
                            returnedDateController.text =
                                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                          }
                        },
                      ),
                    ),
                    readOnly: true, // ทำให้ไม่สามารถแก้ไขข้อความได้
                  )
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 106, 113,
                            213), // สีพื้นหลังของปุ่ม (ถ้าต้องการ)
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();

                        final prefs = await SharedPreferences.getInstance();
                        String? token = prefs.getString('token');

                        // Decode JWT token to get user_id
                        final jwt = JWT.decode(token!);
                        final payload = jwt.payload;
                        final borrowerId = payload['userId']; // ดึงค่า userId
                        final movieId = id;

                        if (borrowerId == null || token == null) {
                          _showErrorDialog(
                              'Error: User not logged in. Please log in again.');
                          return;
                        }

                        try {
                          // Make the API call to borrow the asset
                          final response = await http.post(
                            //=================เปลี่ยน ip=========================================
                            Uri.parse(
                                'http://10.0.1.239:3000/user/borrow/$borrowerId'),
                            headers: {
                              'Authorization': ' $token',
                              'Content-Type': 'application/json',
                            },
                            body: jsonEncode({
                              'date_start':
                                  borrowDateController.text, // Borrow date
                              'date_end':
                                  returnedDateController.text, // Return date
                              'movie_id': movieId, // Movie ID
                            }),
                          );

                          if (response.statusCode == 201) {
                            // Show Snackbar with success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'You have successfully borrowed "$title".',
                                  style: TextStyle(fontSize: 12),
                                ),
                                backgroundColor:
                                    const Color.fromARGB(255, 20, 20, 20),
                                duration: Duration(seconds: 2),
                              ),
                            );

                            //จองเสร็จ
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HistoryUser()),
                            );
                          } else {
                            _showErrorDialog(
                                'Error: Failed to borrow the asset. Status Code: ${response.statusCode}');
                          }
                        } catch (e) {
                          _showErrorDialog('An error occurred: $e');
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 210, 91, 54),
                      ),
                      child: const Text('Confirm',
                          style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255))),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 6, // ระยะเบลอของเงา
            offset: Offset(0, 4), // เงาจะยื่นออกมาจากตรงไหน
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
                SizedBox(
                  width: 10,
                ),
                // รูปภาพที่ด้านซ้าย
                Image.asset(
                  categoryImages[value] ?? 'assets/images/default.png',
                  width: 24, // ขนาดของรูปภาพ
                  height: 24,
                ),
                SizedBox(
                  width: 10,
                ),
                // ข้อความที่แสดงประเภท
                Expanded(
                  // ใช้ Expanded เพื่อให้ข้อความขยายเต็มที่
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 20, // ขนาดข้อความ
                      fontWeight: FontWeight.w500, // น้ำหนักของตัวอักษร
                      color: Colors.black, // สีของข้อความ
                    ),
                    overflow: TextOverflow.ellipsis, // ข้อความไม่พอจะตัด
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        hint: const Text('Select Category'),
        underline: Container(), // เอาเส้นข้างล่างออก
        isExpanded: true, // ใช้ isExpanded ให้ DropdownButton ขยายเต็มพื้นที่
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
          icon: _buildIcon('Assets/image/history (1).png', 2),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon('Assets/image/logout.png', 3),
          label: 'Log out',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.black,
      showUnselectedLabels: true,
      onTap: (index) {
        if (index == 3) {
          _showLogoutConfirmation();
          return;
        }
        switch (index) {
          case 0:
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomeUser()));
            break;
          case 2:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HistoryUser(profileImage: widget.profileImage)));
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
}

Widget _buildStatusButton(int status) {
  Color statusColor;
  String statusText;

  switch (status) {
    case 1:
      statusColor = Colors.green;
      statusText = 'Available';
      break;
    case 4:
      statusColor = Colors.blueGrey;
      statusText = 'borrowed';
      break;
    case 2:
      statusColor = Colors.red;
      statusText = 'Disabled';
      break;
    case 3:
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

class AssetCard extends StatelessWidget {
  final Map<String, dynamic> asset;
  final VoidCallback onTap;

  const AssetCard({required this.asset, required this.onTap, Key? key})
      : super(key: key);

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
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blueGrey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.asset(
                  asset['pic'] ?? 'assets/placeholder_image.png',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                ),
              ),
              // Wrap the content inside a SingleChildScrollView to avoid overflow
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        asset['movie_name'] ?? 'Unknown Movie',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${asset['movie_id'] ?? 'Unknown'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      _buildStatusButton(asset['status_movie'] ?? 0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
