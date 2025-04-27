import 'package:flutter/material.dart';

class BorrowBookAppRequest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BorrowBookScreen(),
    );
  }
}

class BorrowBookScreen extends StatefulWidget {
  @override
  _BorrowBookScreenState createState() => _BorrowBookScreenState();
}

class _BorrowBookScreenState extends State<BorrowBookScreen> {
  TextEditingController returnDateController = TextEditingController();
  int _selectedIndex = 1; // Start with the "Assets Lists" tab selected

  // Function to show date picker
  Future<void> _selectReturnDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        // Format the selected date
        returnDateController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  // Method to show dialog alert
  void _showBorrowDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Borrow Confirmation'),
          content: Text('Do you want to borrow this movie?'),
          actions: [
            TextButton(
              onPressed: () {
                // Handle borrow action here
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  // Method to handle bottom navigation item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Add your navigation logic here
    switch (index) {
      case 0:
        // Navigate to Home
        break;
      case 1:
        // "Assets Lists" already selected, do nothing or show a message
        break;
      case 2:
        // Navigate to Status
        break;
      case 3:
        // Navigate to History
        break;
      case 4:
        // Handle Log out
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0), // Set height for AppBar
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4c8479), // Starting color
                Color(0xFF2b5f56), // Ending color
              ],
              begin: Alignment.centerLeft, // Gradient starts from the left
              end: Alignment.centerRight, // Gradient ends at the right
            ),
          ),
          child: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the text
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Borrow Movie',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            leading: Padding(
              padding:
                  const EdgeInsets.only(left: 16.0), // Padding for the icon
              child: Image.asset(
                'assets/image/video-player.png',
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/image/proflie.jpg'),
                ),
              ),
            ],
            backgroundColor: Colors.transparent, // Make AppBar transparent
            elevation: 0, // Remove shadow
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255), // Starting color
              Color.fromARGB(255, 165, 165, 165), // Ending color
            ],
            begin: Alignment.topCenter, // Gradient starts from the top
            end: Alignment.bottomCenter, // Gradient ends at the bottom
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Wrap the Image.asset in a Container with BoxDecoration for shadow
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(12), // Optional: Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5), // Shadow color
                        spreadRadius: 5, // Spread radius
                        blurRadius: 10, // Blur radius
                        offset: Offset(0, 3), // Shadow position
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        12), // Optional: Rounded corners for the image
                    child: Image.asset(
                      'assets/image/avengers.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Action',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Divider(),
                        Text('Book ID: A0005', style: TextStyle(fontSize: 16)),
                        Text('Book Name: AVENGERS',
                            style: TextStyle(fontSize: 16)),
                        Text('Borrow Date: 16/10/2024',
                            style: TextStyle(fontSize: 16)),
                        TextField(
                          controller: returnDateController,
                          readOnly: true, // Prevent manual input
                          decoration: InputDecoration(
                            labelText: 'Return Date',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () => _selectReturnDate(context),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Handle back action here
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue),
                              child: Text('Back',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            ElevatedButton(
                              onPressed:
                                  _showBorrowDialog, // Show dialog when pressed
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: Text('Borrow',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4c8479), // Starting color
              Color(0xFF2b5f56), // Ending color
            ],
            begin: Alignment.topLeft, // Gradient starts from the left
            end: Alignment.topRight, // Gradient ends at the right
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent, // Make background transparent
          selectedItemColor: Colors.white,
          unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.movie_rounded),
              label: 'Lists',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.playlist_add_check_rounded),
              label: 'Status',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              label: 'Log out',
            ),
          ],
        ),
      ),
    );
  }
}
