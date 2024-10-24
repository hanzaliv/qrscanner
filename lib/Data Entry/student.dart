import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'dart:convert';  // For decoding JSON
import 'package:http/http.dart' as http;

import 'package:dropdown_search/dropdown_search.dart';
import 'studentModify.dart';
import '../session_manager.dart';
import '../.env';
import '../menu.dart';



class Student extends StatefulWidget {
  const Student({super.key});

  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {

  final dropDownKeyFind = GlobalKey<DropdownSearchState>();
  Map<String, String> studentMap = {}; // To store the name and ID mapping
  List<String> studentNames = []; // To store only the names for the dropdown

  final _scrollController = ScrollController();
  final _focusNodes = List<FocusNode>.generate(10, (index) => FocusNode());
  bool _obscureText = true;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController regNoController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? search;
  String? selectedStudentId;
  String? id;
  String? name;
  String? email;
  String? phone;
  String? password;
  String? confirmPassword;
  String? username;
  String? regNo;

  Future<void> addStudent(String username, String password, String name, String email, String phone, String regNo) async {
    try {


      final sessionManager = SessionManager(); // Retrieve the singleton instance

      // Prepare the request body
      var body = jsonEncode({
        'username': username,
        'password': password,
        'name': name,
        'email': email,
        'phone': phone,
        'sc_number' : regNo
      });

      final response = await http.post(
        Uri.parse('$SERVER/add-student'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json', // Indicate that the body is JSON
          'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
        },
        body: body, // Send the student details in the request body
      );

      if (response.statusCode == 201) {
        var jsonResponse = json.decode(response.body);
        id = jsonResponse['id'].toString();
        // print('student added successfully with ID: $id');
        // Save the student ID as needed
      } else {
        // print('Failed to add student: ${response.body}');
      }
    } catch (error) {
      // print('Error adding student: $error');
    }
  }

  Future<void> _fetchStudents() async {
    try {
      final sessionManager = SessionManager(); // Retrieve the singleton instance

      final response = await http.get(
        Uri.parse('$SERVER/students'),
        headers: {
          'Accept': 'application/json',
          'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);

        setState(() {
          // Map student names to their IDs
          studentMap = {
            for (var course in jsonResponse)
              course['name'].toString(): course['id'].toString()
          };
          studentNames = studentMap.keys.toList(); // List of student names for dropdown
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load students')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching students: $error')),
      );
    }
  }


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
    _fetchStudents(); // Call the function to fetch students on page load

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

      drawer: const Menu(),
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
                      'Student',
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
                                  child:DropdownSearch<String>(
                                    key: dropDownKeyFind,
                                    // items: (filter, infiniteScrollProps) => _fetchCourses(),
                                    items: (filter, infiniteScrollProps) => studentNames, // Use the fetched course units
                                    onChanged: (value) {
                                      setState(() {
                                        search = value; // Update selected course unit
                                        selectedStudentId = studentMap[value!];
                                      });
                                    },
                                    selectedItem: search,
                                    popupProps: PopupProps.menu(
                                      showSearchBox: true,
                                      fit: FlexFit.loose,
                                      constraints: BoxConstraints(
                                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                                        maxWidth: 308,
                                      ),
                                      containerBuilder: (context, popupWidget) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE1FCE2), // Same background color
                                            borderRadius: BorderRadius.circular(0), // Same border radius
                                          ),
                                          width: 308, // Set the width of the popup
                                          child: popupWidget, // Return the actual popup content
                                        );
                                      },
                                      searchFieldProps: TextFieldProps(
                                        decoration: InputDecoration(
                                          hintText: 'Search', // Placeholder text
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(25), // Rounded border
                                            borderSide: const BorderSide(
                                              color: Colors.grey, // Border color
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(25), // Rounded border when focused
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0), // Adjust padding
                                        ),
                                      ),
                                    ),
                                    decoratorProps: DropDownDecoratorProps(
                                      decoration  : InputDecoration(
                                        filled: true,
                                        fillColor: const Color(0xFFE1FCE2), // Set background color
                                        contentPadding: const EdgeInsets.symmetric(vertical: 0), // Adjust padding to fit height
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25), // Rounded border
                                          borderSide: const BorderSide(
                                            color: Colors.transparent, // No border color
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25), // Same rounded border when focused
                                          borderSide: const BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: const BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        // Set the label text and border behavior when label is focused
                                      ),
                                    ),
                                    dropdownBuilder: (context, selectedItem) => Container(
                                      alignment: Alignment.centerLeft,
                                      width: 308, // Set width to 308
                                      height: 35,  // Set height to 35
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        selectedItem ?? "Search",
                                        style: const TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: Colors.black45, // You can customize the text style
                                        ),
                                      ),
                                    ),
                                  )

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
                              if(search == null) {
                                _showAlertDialog(context, 'Please select a student');
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ModifyStudent(
                                      id: selectedStudentId!,
                                      name: search!,
                                    ),
                                  ),
                                );
                              }
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
                                'Username: ',
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
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1FCE2),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: TextField(
                                  controller: usernameController,
                                  focusNode: _focusNodes[0],
                                  decoration: const InputDecoration(
                                    hintStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      username = value;
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
                                'Student Name: ',
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
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1FCE2),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: TextField(
                                  controller: nameController,
                                  focusNode: _focusNodes[1],
                                  decoration: const InputDecoration(
                                    hintStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      name = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Expanded(
                              flex: 5,
                              child: Text(
                                'Registration Number: ',
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
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1FCE2),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: TextField(
                                  controller: regNoController,
                                  focusNode: _focusNodes[2],
                                  decoration: const InputDecoration(
                                    hintText: 'XX/20XX/xxxxx',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (value) {
                                    setState(() {
                                      regNo = value;
                                      if (!RegExp(r'^[A-Za-z]{2}/20\d{2}/\d{5}$').hasMatch(regNo!)) {
                                        _showAlertDialog(context, 'Registration number must be in the format XX/20XX/xxxxx');
                                        regNo = null;
                                      }
                                    });
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      regNo = value;
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
                                'Email: ',
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
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1FCE2),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: TextField(
                                  controller: emailController,
                                  focusNode: _focusNodes[4],
                                  decoration: const InputDecoration(
                                    hintStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (value) {
                                    setState(() {
                                      email = value;
                                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email!)) {
                                        _showAlertDialog(context, 'Invalid email format');
                                        email = null;
                                      }
                                    });
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      email = value;
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
                                'Phone Number: ',
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
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1FCE2),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: TextField(
                                  controller: phoneController,
                                  focusNode: _focusNodes[5],
                                  decoration: const InputDecoration(
                                    hintStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (value) {
                                    setState(() {
                                      phone = value;
                                      if (!RegExp(r'^\d{9,10}$').hasMatch(phone!)) {
                                        _showAlertDialog(context, 'Phone number must be 9 or 10 digits');
                                        phone = null;
                                      }
                                    });
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      phone = value;
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
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1FCE2),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: TextField(
                                  controller: passwordController,
                                  focusNode: _focusNodes[6],
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password',
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
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      password = value;
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
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1FCE2),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: TextField(
                                  controller: confirmPasswordController,
                                  focusNode: _focusNodes[7],
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password',
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
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                    ),
                                  ),
                                  onSubmitted: (value) {
                                    setState(() {
                                      confirmPassword = value;
                                      if (password != confirmPassword) {
                                        _showAlertDialog(context, 'Passwords do not match');
                                        confirmPassword = null;
                                      }
                                    });
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      confirmPassword = value;
                                    });
                                  },
                                ),
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
                                  backgroundColor: const Color(0xFF88C98A),
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(color: Colors.white, width: 2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () async {
                                  if (name == null || name!.isEmpty ||
                                      email == null || email!.isEmpty ||
                                      phone == null || phone!.isEmpty ||
                                      regNo == null || regNo!.isEmpty ||
                                      password == null || password!.isEmpty ||
                                      confirmPassword == null || confirmPassword!.isEmpty) {
                                    _showAlertDialog(context, 'Please fill in all fields');
                                  } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email!)) {
                                    _showAlertDialog(context, 'Invalid email format');
                                  } else if (!RegExp(r'^\d{9,10}$').hasMatch(phone!)) {
                                    _showAlertDialog(context, 'Phone number must be 9 or 10 digits');
                                  } else if (password != confirmPassword) {
                                    _showAlertDialog(context, 'Passwords do not match');
                                  } else {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return const AlertDialog(
                                          title: Text('Adding New student'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircularProgressIndicator(),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                    try {
                                      await addStudent(username!,password!, name!, email!, phone!, regNo!);
                                      Navigator.pop(context); // Close the progress dialog
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Success'),
                                            content: const Text('Student added successfully'),
                                            actions: [
                                              TextButton(
                                                child: const Text('OK'),
                                                onPressed: () {
                                                  Navigator.pop(context); // Close the success dialog
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => ModifyStudent(
                                                        id: id!,
                                                        name: name!,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } catch (error) {
                                      Navigator.pop(context); // Close the progress dialog
                                      _showAlertDialog(context, 'Failed to add student: $error');
                                    }
                                  }
                                },
                                child: const Text(
                                  'Save',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF88C98A),
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(color: Colors.white, width: 2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    usernameController.clear();
                                    nameController.clear();
                                    emailController.clear();
                                    phoneController.clear();
                                    passwordController.clear();
                                    confirmPasswordController.clear();
                                    regNoController.clear();
                                  });
                                },
                                child: const Text(
                                  'Clear',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                    color: Colors.white,
                                  ),
                                ),
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


