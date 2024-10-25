import 'package:flutter/material.dart';
import 'home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'session_manager.dart'; // Import the session manager

import '.env';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordObscured = true;
  String? role;
  String? id;

  void showTopSnackBar(BuildContext context, String message, Color color) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0, // You can adjust the position
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color, // Set the background color based on the input
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Remove the overlay after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  // Function to handle login
  Future<void> _login() async {

    _showLoadingDialog(context); // Show loading dialog

    String username = _usernameController.text;
    String password = _passwordController.text;

    bool loginSuccess = false;

    try {
      var response = await http.post(
        Uri.parse('$SERVER/auth/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // String message = data['message'];
        role = data['role'];
        id = data['user_id'].toString();
        UserSession().userRole = role;
        UserSession().userId = id;

        // Extract cookies from the response headers
        String? sessionCookie = response.headers['set-cookie']?.split(';')[0];
        String? csrfCookie = response.headers['set-cookie']?.split(';')[1];

        if (sessionCookie != null && csrfCookie != null) {
          // Save session and role using the SessionManager singleton
          SessionManager().saveSession(sessionCookie, csrfCookie, role!, username);
          loginSuccess = true;

          // Show a success message
          showTopSnackBar(context, 'Login successful', Colors.green);
        }
      } else {
        // print('Login failed with status code ${response.statusCode}');
        // Show an error message if login fails
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed')),
        );
      }
    } catch (e) {
      // Handle network or other errors
      // print('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during login: $e')),
      );
    }finally{
      Navigator.of(context).pop(); // Close the loading dialog
    }

    if (loginSuccess) {
      // Navigate to the Home page if login is successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home(
          userRole: role!,
          userId: id!,
        )),
      );
    }

  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF88C98A),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Image.asset(
                  'assets/images/phone.png',
                  height: 200,
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          //watermark image
                          opacity: 0.1,
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                        ),

                        Column(
                          children: [
                            const Text(
                              'QR Vault',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'User Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _passwordController,
                              obscureText: _isPasswordObscured,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordObscured
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    // Toggle the password visibility
                                    setState(() {
                                      _isPasswordObscured = !_isPasswordObscured;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Log In'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _usernameController.clear();
                                    _passwordController.clear();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Clear'),
                                ),
                              ],
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
      );

  }
}
