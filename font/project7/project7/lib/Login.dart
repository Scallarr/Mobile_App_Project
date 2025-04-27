import 'package:flutter/material.dart';
import 'package:project/Admin/Home_Admin.dart';
import 'package:project/Approver/Home_Approver.dart';
import 'package:project/User/Home_User.dart';
import 'package:project/register.dart'; // Import the Register page
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A776F),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with App Title
              Image.asset(
                'Assets/image/logo.png', // Replace with your logo
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              // Username
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person, color: Colors.white70),
                  hintText: "Username",
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),

              // Password
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                  hintText: "Password",
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 30),

              // Login
              ElevatedButton(
                onPressed: () {
                  _handleLogin(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              // "or" Text
              const Text(
                "or",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),

              // Create Account Button
              OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                ),
                child: const Text(
                  "Create an account",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context) async {
    String username = usernameController.text;
    String password = passwordController.text;

    try {
      final response = await http.post(
        //=================เปลี่ยน ip=========================================
        Uri.parse('http://10.0.1.239:3000/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // เก็บ user data ลง SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userId', data['userId'].toString());
        prefs.setString('token', data['token']);
        prefs.setInt('role', data['role']);

        // ใช้ payload
        final jwt = JWT.decode(data['token']);
        print(data['token']);

        String userId =
            jwt.payload['userId']?.toString() ?? ''; // จัดการต่า null
        int role = jwt.payload['role'] != null
            ? int.tryParse(jwt.payload['role'].toString()) ?? 0
            : 0;
        //print ดู User Id
        print("User ID from payload: $userId");
        print("User role from payload: $role");

        // ย้ายหน้าตามrole
        if (role == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeUser()),
          );
        } else if (role == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeAdmin()),
          );
        } else if (role == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeApprover()),
          );
        }
      } else {
        _showErrorDialog(context);
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog(context);
    }
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Failed'),
        content: const Text('Invalid username or password.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
