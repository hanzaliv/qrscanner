import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'dart:convert';  // For decoding JSON
import 'package:http/http.dart' as http;

import 'package:dropdown_search/dropdown_search.dart';
import 'groupModify.dart'
;import '../session_manager.dart';
import '../.env';

class Group extends StatefulWidget {
  const Group({super.key});

  @override
  State<Group> createState() => _GroupState();
}

class _GroupState extends State<Group> {

  final dropDownKeyFind = GlobalKey<DropdownSearchState>();
  Map<String, String> groupMap = {}; // To store the name and ID mapping
  List<String> groupNames = []; // To store only the names for the dropdown

  final _scrollController = ScrollController();
  final _focusNodes = List<FocusNode>.generate(10, (index) => FocusNode());

  final TextEditingController nameController = TextEditingController();


  String? search;
  String? selectedStudentId;
  String? selectedGroupId;
  String? id;
  String? name;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
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

  @override
  void dispose() {
    // _usernameController.dispose();
    // _nameController.dispose();
    // _emailController.dispose();
    // _phoneController.dispose();
    // _passwordController.dispose();
    // _confirmPasswordController.dispose();
    // Clean up focus nodes to avoid memory leaks
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchGroups() async {
    try {
      final sessionManager = SessionManager(); // Retrieve the singleton instance

      final response = await http.get(
        Uri.parse('$SERVER/get-student-groups'),
        headers: {
          'Accept': 'application/json',
          'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);

        setState(() {
          // Map lecturer names to their IDs
          groupMap = {
            for (var group in jsonResponse)
              group['name'].toString(): group['id'].toString()
          };
          groupNames = groupMap.keys.toList(); // List of lecturer names for dropdown
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load groups')),
        );
        print('Failed to load groups: ${response.body}');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching groups: $error')),
      );
    }
  }

  Future<void> addGroup(String name) async {
    try {
      print('Adding Group with name: $name');

      final sessionManager = SessionManager(); // Retrieve the singleton instance

      // Prepare the request body
      var body = jsonEncode({
        'name': name,
      });

      final response = await http.post(
        Uri.parse('$SERVER/add-student-group'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json', // Indicate that the body is JSON
          'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
        },
        body: body, // Send the Group details in the request body
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        id = jsonResponse['group_id'].toString();
        print('Group added successfully with ID: $id');
        // Save the Group ID as needed
      } else {
        print('Failed to add Group: ${response.body}');
      }
    } catch (error) {
      print('Error adding Group: $error');
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
                      'Group',
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
                                    items: (filter, infiniteScrollProps) => groupNames, // Use the fetched course units
                                    onChanged: (value) {
                                      setState(() {
                                        search = value; // Update selected course unit
                                        selectedGroupId = groupMap[value!];
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
                              if(selectedGroupId == null) {
                                _showAlertDialog(context, 'Please select a group');
                              } else {
                                // Fetch the group details
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ModifyGroup(
                                        selectedId: selectedGroupId!,
                                        selectedName: search!,
                                      )
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
                                'Add New Group',
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
                        _buildTextField('Name', 'PHY2222 2024' , nameController, _focusNodes[0]),


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
                                  if (nameController.text.isEmpty) {
                                    _showAlertDialog(context, 'Please fill in all fields');
                                  } else {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return const AlertDialog(
                                          title: Text('Adding New Group'),
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
                                      await addGroup(
                                        nameController.text,
                                      );
                                      Navigator.pop(context); // Close the progress dialog
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Success'),
                                            content: const Text('Group added successfully'),
                                            actions: [
                                              TextButton(
                                                child: const Text('OK'),
                                                onPressed: () {
                                                  Navigator.pop(context); // Close the success dialog
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => ModifyGroup(
                                                        selectedId: id!,
                                                        selectedName: nameController.text,
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
                                      _showAlertDialog(context, 'Failed to add Group: $error');
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
                                  nameController.clear();
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

Widget _buildTextField(String label, String placeholder, TextEditingController controller, FocusNode focusNode, {bool obscureText = false}) {
  return Row(
    children: [
      Expanded(
        flex: 5,
        child: Text(
          '$label: ',
          style: const TextStyle(
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
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintStyle: const TextStyle(color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              border: InputBorder.none,
              hintText: placeholder,
            ),
          ),
        ),
      ),
    ],
  );
}


