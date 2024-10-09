import 'package:flutter/material.dart';

class Loggin extends StatefulWidget {
  const Loggin({super.key});

  @override
  State<Loggin> createState() => _LogginState();
}

class _LogginState extends State<Loggin> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFF88C98A), 
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            children: [
              // Welcome text at the top
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

             const  SizedBox(height: 20), // Space between elements

              // Image displayed below Welcome text
              Image.asset(
                'assets/images/phone.png',
                height: 200,
              ),

              SizedBox(height: 30), // Space between image and login box

              // Login box container with rounded corners and shadow
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // QR Vault title inside the login box
                      Text(
                        'QR Vault',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      SizedBox(height: 20), // Space between title and input fields

                      // Username input field
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'User Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      SizedBox(height: 10), // Space between input fields

                      // Password input field with eye icon for visibility toggle
                      TextField(
                        obscureText: true, // Hides the password
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: Icon(Icons.visibility_off), // Eye icon
                        ),
                      ),

                      SizedBox(height: 20), // Space between input fields and buttons

                      // Row of buttons: Log In and Clear
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Log In button
                          ElevatedButton(
                            onPressed: () {
                              // Handle log in action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black, // Button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Log In'),
                          ),

                          // Clear button
                          ElevatedButton(
                            onPressed: () {
                              // Handle clear action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // Button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Clear'),
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