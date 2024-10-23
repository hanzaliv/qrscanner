import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'dart:convert';  // For decoding JSON
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'courseModify.dart';
import '../session_manager.dart';
import '../.env';



class Course extends StatefulWidget {
  const Course({super.key});

  @override
  State<Course> createState() => _CourseState();
}

class _CourseState extends State<Course> {

  final dropDownKeyLecturer = GlobalKey<DropdownSearchState>();
  final dropDownKeyFind = GlobalKey<DropdownSearchState>();

  TextEditingController courseNumberController = TextEditingController();
  TextEditingController courseNameController = TextEditingController();

  List<Map<String, dynamic>> courses = []; // To store the course details
  List<String> courseUnitNumbers = []; // List of course unit numbers for the dropdown
  List<String> courseUnitNames = []; // List of course unit names for the dropdown

  String? search;
  String? courseNumber;
  String? courseName;
  String? lecturer;

  Future<List<String>> _fetchCourses() async {
    try {
      final sessionManager = SessionManager(); // Retrieve the singleton instance

      final response = await http.get(
        Uri.parse('$SERVER/get-courses'),
        headers: {
          'Accept': 'application/json',
          'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
        },
      );

      if (response.statusCode == 200) {

        List<dynamic> jsonResponse = json.decode(response.body);

        setState(() {
          // Extract course_unit_number from the response and store it in courseUnitNumbers list
          courseUnitNumbers = jsonResponse
              .map((course) => course['course_unit_number'].toString())
              .toList();
        });

        return jsonResponse
            .map<String>((course) => course['course_unit_number'].toString())
            .toList();
      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load courses')),
        );
        return []; // Return empty list on failure
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching courses: $error')),
      );
      return []; // Return empty list on error
    }
  }
  @override
  void initState() {
    super.initState();
    _fetchCourses(); // Call the function to fetch courses on page load
  }

  @override
  void dispose() {
    // Dispose the controllers when the widget is removed from the tree
    courseNumberController.dispose();
    courseNameController.dispose();
    super.dispose();
  }

  void clearSelections() {
    setState(() {
      lecturer = null;   // Clear lecturer
      courseNumberController.clear(); // Clear the course number TextField
      courseNameController.clear();   // Clear the course name TextField
    });
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
                      'Course',
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
                                  items: (filter, infiniteScrollProps) => courseUnitNumbers, // Use the fetched course units
                                  onChanged: (value) {
                                    setState(() {
                                      search = value; // Update selected course unit
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
                                _showAlertDialog(context, 'Please select a course unit');
                              } else {
                                // Save the course details
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ModifyCourses(),
                                  ),
                                );
                              }                            },
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
                                'Course Unit Number: ',
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
                                  controller: courseNumberController,
                                  decoration: const InputDecoration(
                                    // hintText: '',
                                    hintStyle: TextStyle(color: Colors.grey), // Optional: style for placeholder
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (value) {
                                    setState(() {
                                      courseNumber = value;
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
                                'Course Unit Name: ',
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
                                  controller: courseNameController,
                                  decoration: const InputDecoration(
                                    // hintText: '',
                                    hintStyle: TextStyle(color: Colors.grey), // Optional: style for placeholder
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (value) {
                                    setState(() {
                                      courseName = value;
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
                                'Lecturer: ',
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
                              child: DropdownSearch<String>(
                                key: dropDownKeyLecturer,
                                items: (filter, infiniteScrollProps) =>
                                ["PHY2222", "PHY12222", "PHY1234", "CSC1232","CHE2163"],
                                onChanged: (value) {
                                  setState(() {
                                    lecturer = value; // Update selected course unit
                                  });
                                },
                                selectedItem: lecturer,
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
                                        color: const Color(0xFFE1FCE2), // Set the same background color
                                        borderRadius: BorderRadius.circular(0), // Set the same border radius
                                      ),
                                      width: 308, // Set the width of the popup
                                      child: popupWidget, // Return the actual popup content inside the styled container
                                    );
                                  },
                                  searchFieldProps: TextFieldProps(
                                    decoration: InputDecoration(
                                      hintText: 'Search', // Set the placeholder text
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25), // Rounded border for search box
                                        borderSide: const BorderSide(
                                          color: Colors.grey, // Border color for the search box
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
                                    selectedItem ?? "", // Display the selected item or placeholder
                                    style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Colors.black, // You can customize the text style
                                    ),
                                  ),
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
                                  backgroundColor: const Color(0xFF88C98A), // Button background color
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(color: Colors.white, width: 2),
                                    borderRadius: BorderRadius.circular(15), // Border radius of 15
                                  ),
            
                                ),
            
                                onPressed: () {
                                  if(courseNumber == null || courseName == null || lecturer == null) {
                                    _showAlertDialog(context, 'Please fill in all fields');
                                  } else {
                                    // Save the course details
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ModifyCourses(),
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
                                  clearSelections();
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
