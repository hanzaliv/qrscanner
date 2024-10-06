import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:dropdown_search/dropdown_search.dart';
import 'lecturerModify.dart';

class Lecturer extends StatefulWidget {
  const Lecturer({super.key});

  @override
  State<Lecturer> createState() => _LecturerState();
}

class _LecturerState extends State<Lecturer> {

  final _scrollController = ScrollController();
  final _focusNodes = List<FocusNode>.generate(5, (index) => FocusNode());
  bool _obscureText = true;

  String? id;
  String? name;
  String? password;
  String? confirmPassword;

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // Listen for keyboard visibility changes
    KeyboardVisibilityController().onChange.listen((bool visible) {
      if (visible) {
        // Scroll to the currently focused TextField when keyboard shows up
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToFocusedField();
        });
      }
    });

    // Attach listeners to each FocusNode
    for (var focusNode in _focusNodes) {
      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          // When this TextField gains focus, scroll to it
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToFocusedField();
          });
        }
      });
    }
  }

  void _scrollToFocusedField() {
    for (int i = 0; i < _focusNodes.length; i++) {
      if (_focusNodes[i].hasFocus) {
        // Scroll to the TextField with focus
        _scrollController.animateTo(
          i * 100.0, // Adjust this value based on the size of your TextFields
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        break;
      }
    }
  }

  @override
  void dispose() {
    // Clean up focus nodes to avoid memory leaks
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Database',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFC7FFC9),
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.person_4_outlined,
                ),
              ),
            ),
            onPressed: () {
              // Handle the notification icon tap action here
            },
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,

      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFFFFFFF), // Start color (FFFFFF)
                Color(0xFFC7FFC9), // End color (C7FFC9)
              ],
              stops: [0.0, 0.82], // Stops as per your gradient
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 100),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 10),
                    Text('Profile'),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 10),
                    Text('Settings'),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: const BoxDecoration(
                color: Color(0xFFC7FFC9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Lecturer',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF88C98A),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Color(0xFF88C98A),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Find',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF88C98A),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Color(0xFF88C98A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: 305,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1FCE2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0), // Adds some padding to the left
                                child: Icon(
                                  Icons.search,
                                  color: Color(0xFF88C98A),
                                ),
                              ),
                              Expanded( // Allows the TextField to take up the remaining space
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: 'Search', // Placeholder text
                                    hintStyle: TextStyle(color: Colors.grey), // Optional: style for placeholder
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (value) {
                                    setState(() {
                                      // search = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 120,
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF88C98A), // Button background color
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(15), // Border radius of 15
                              ),
                            ),
                            onPressed: () {
                              // Handle the scan button tap action here
                            },
                            child: const Text(
                                'Enter',
                                style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                    color: Colors.white
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'OR',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF88C98A),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Color(0xFF88C98A),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Add New',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF88C98A),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Color(0xFF88C98A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Expanded(
                              flex: 5,
                              child: Text(
                                'Lecturer ID: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Container(
                                // width: 100,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1FCE2),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: TextField(
                                  focusNode: _focusNodes[0],
                                  // controller: courseNumberController,
                                  decoration: const InputDecoration(
                                    // hintText: '',
                                    hintStyle: TextStyle(color: Colors.grey), // Optional: style for placeholder
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (value) {
                                    setState(() {
                                      id = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Expanded(
                              flex: 5,
                              child: Text(
                                'Lecturer Name: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Container(
                                // width: 100,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1FCE2),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: TextField(
                                  focusNode: _focusNodes[1],
                                  // controller: courseNameController,
                                  decoration: const InputDecoration(
                                    // hintText: '',
                                    hintStyle: TextStyle(color: Colors.grey), // Optional: style for placeholder
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (value) {
                                    setState(() {
                                      name = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Expanded(
                              flex: 5,
                              child: Text(
                                'Password: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Container(
                                // width: 100,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1FCE2),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: TextField(
                                  focusNode: _focusNodes[2],
                                  obscureText: _obscureText, // Toggles the visibility
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password', // Placeholder text
                                    hintStyle: const TextStyle(color: Colors.grey),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    border: InputBorder.none,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText; // Toggle the password visibility
                                        });
                                      },
                                    ),
                                  ),
                                  onSubmitted: (value) {
                                    setState(() {
                                      password = value;
                                      // You can save the password value here
                                    });
                                  },
                                )
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Expanded(
                              flex: 5,
                              child: Text(
                                'Confirm Password: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Container(
                                // width: 100,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE1FCE2),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: TextField(
                                    focusNode: _focusNodes[3],
                                    obscureText: _obscureText, // Toggles the visibility
                                    decoration: InputDecoration(
                                      hintText: 'Enter your password', // Placeholder text
                                      hintStyle: const TextStyle(color: Colors.grey),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      border: InputBorder.none,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureText ? Icons.visibility : Icons.visibility_off,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureText = !_obscureText; // Toggle the password visibility
                                          });
                                        },
                                      ),
                                    ),
                                    onSubmitted: (value) {
                                      setState(() {
                                        confirmPassword = value;
                                        if(password != confirmPassword) {
                                          _showAlertDialog(context, 'Passwords do not match');
                                          confirmPassword = null;
                                        }
                                      });
                                    },
                                  )
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF88C98A), // Button background color
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(color: Colors.white, width: 2),
                                    borderRadius: BorderRadius.circular(15), // Border radius of 15
                                  ),

                                ),

                                onPressed: () {
                                  if(name == null || id == null || password == null || confirmPassword == null) {
                                    _showAlertDialog(context, 'Please fill in all fields');
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ModifyLecturer(),
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                    'Save',
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17,
                                        color: Colors.white
                                    )),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF88C98A), // Button background color
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(color: Colors.white, width: 2),
                                    borderRadius: BorderRadius.circular(15), // Border radius of 15
                                  ),

                                ),

                                onPressed: () {
                                  // clearSelections();
                                },
                                child: const Text(
                                    'Clear',
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17,
                                        color: Colors.white
                                    )),
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 200,)
                ],
              ),
            ),
          )

        ],
      ),
      floatingActionButton: SizedBox(
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

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomAppBar(
        color: Colors.white,
        shape: CircularNotchedRectangle(),
        notchMargin: 15.0,
        height: 100,
      ),
    );
  }
}
