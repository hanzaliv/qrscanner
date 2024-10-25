import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  final picker = ImagePicker();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Positioned background at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: const BoxDecoration(
                color: Color(0xFFC7FFC9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
            ),
          ),

          // Foreground content: Scrollable page content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 20), // Add spacing to avoid overlap

                // Profile Image Section
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : const AssetImage('assets/default_profile.png')
                              as ImageProvider,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Color.fromARGB(255, 37, 119, 55),
                        size: 30,
                      ),
                      onPressed: _pickImage,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "User Information",
                  style: TextStyle(
                    color: Color.fromARGB(255, 37, 119, 55),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // User Details Section
                Container(
                  decoration: BoxDecoration(
                    color:  Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Center(
                          child: Text(
                          "Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 10),
                      _buildTextField("Full Name", nameController),
                      const SizedBox(height: 10),
                      _buildTextField("Email", emailController),
                      const SizedBox(height: 10),
                      _buildTextField("Phone Number", phoneController),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // // QR Scanner Button Section
                // CircleAvatar(
                //   radius: 30,
                //   backgroundColor: Colors.white,
                //   child: IconButton(
                //     icon: const Icon(Icons.qr_code_scanner, size: 30),
                //     onPressed: () {
                //       // Add QR scan logic here
                //     },
                //   ),
                // ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.18), // Prevent content overlap with bottom container
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100.0,
            height: 100.0,
            child: FloatingActionButton(
                backgroundColor: Color(0xFFC7FFC9),
                elevation: 0,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: BorderSide.none,
                ),
                onPressed: () {
                // Handle action when the red floating button is pressed
                },
              child: Container(), // Empty container to make it a plain red circle
            ),
          ),
          SizedBox(
            width: 75.0,
            height: 75.0,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              shape: const CircleBorder(
                side: BorderSide(
              color: Colors.white,
              width: 2.0,
                ),
              ),
              onPressed: () {
                // Handle action when the floating button is pressed
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      //   width: 75.0,
      //   height: 75.0,
      //   child: FloatingActionButton(
      //     backgroundColor: Colors.white,
      //     shape: const CircleBorder(
      //       side: BorderSide(
      //         color: Colors.white,
      //         width: 2.0,
      //       ),
      //     ),
      //     onPressed: () {
      //       // Handle action when the floating button is pressed
      //     },
      //     child: Padding(
      //       padding: const EdgeInsets.all(10.0),
      //       child: Image.asset(
      //         'assets/images/logo.png',
      //         fit: BoxFit.cover,
      //       ),
      //     ),
      //   ),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomAppBar(
        color: Colors.white,
        shape: CircularNotchedRectangle(),
        notchMargin: 15.0,
        height: 100,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            "$label:",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 3,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.green[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
