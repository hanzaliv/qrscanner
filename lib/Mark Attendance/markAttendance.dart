
import 'package:flutter/material.dart';
import 'dart:convert';  // For decoding JSON
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:dropdown_search/dropdown_search.dart';
import '../.env';

import '../session_manager.dart';
import 'scanner.dart';

class MarkAttendance extends StatefulWidget {
  const MarkAttendance({super.key});

  @override
  State<MarkAttendance> createState() => _MarkAttendanceState();
}

class _MarkAttendanceState extends State<MarkAttendance> {

  List<Map<String, dynamic>> courses = []; // To store the course details
  List<String> courseUnitNumbers = []; // List of course unit numbers for the dropdown


  final dropDownKeyCourseUnit = GlobalKey<DropdownSearchState>();
  final dropDownKeyLecturer = GlobalKey<DropdownSearchState>();
  final dropDownKeyStudentGroup = GlobalKey<DropdownSearchState>();

  Map<String, String> lecturerMap = {}; // To store the name and ID mapping
  List<String> lecturerNames = []; // To store only the names for the dropdown
  Map<String, String> studentGroupMap = {}; // To store the name and ID mapping
  List<String> studentGroupNames = []; // To store only the names for the dropdown
  String? lectureId; // To store the ID of the lecture

  String? selectedLecturerId; // To store the selected lecturer's ID
  String? selectedLecturerName; // To store the selected lecturer's name
  String? selectedCourseUnit;
  String? selectedLecturer;
  String? selectedStudentGroupId;
  String? selectedStudentGroupName;
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool? isLectureAdded;

  @override
  void initState() {
    super.initState();
    _fetchCourses(); // Call the function to fetch courses on page load
    _fetchLecturers(); // Call the function to fetch lecturers on page load
    _fetchStudentGroups(); // Call the function to fetch student groups on page load
  }

  DateTime convertTimeOfDayToDateTime(TimeOfDay timeOfDay) {
    final now = DateTime.now(); // Get the current date
    return DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  }

  Future<void> _addLecture() async {
    try {
      var formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      var formattedStartTime = DateFormat('HH:mm').format(convertTimeOfDayToDateTime(startTime!));
      var formattedEndTime = DateFormat('HH:mm').format(convertTimeOfDayToDateTime(endTime!));

      final sessionManager = SessionManager(); // Retrieve the singleton instance

      // Prepare the request body
      var body = jsonEncode({
        'course_id': selectedCourseUnit,
        'lecture_user_id': selectedLecturerId,
        'date': formattedDate,
        'from': formattedStartTime,
        'to': formattedEndTime,
        'student_group_id': selectedStudentGroupId,
      });

      final response = await http.post(
        Uri.parse('$SERVER/add-lecture'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json', // Indicate that the body is JSON
          'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
        },
        body: body, // Send the sc_number in the request body
      );

      if (response.statusCode == 201) {
        var jsonResponse = json.decode(response.body);

        setState(() {
          isLectureAdded = true;
          // print('jsonResponse: $jsonResponse');
          lectureId = jsonResponse['lecId'].toString();
        });
      } else {
        isLectureAdded = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add lecture')),
        );
        // print("status code: ${response.statusCode}");
        // var jsonResponse = json.decode(response.body);
        // print('jsonResponse: $jsonResponse');



      }
    } catch (error, stackTrace) {
      // print('Error: $error');
      // print('StackTrace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding lecture: $error')),
      );
    }

  }

  // Function to fetch courses from the server
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
          const SnackBar(content: Text('Failed to load courses')),
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

  Future<void> _fetchLecturers() async {
    try {
      final sessionManager = SessionManager(); // Retrieve the singleton instance

      final response = await http.get(
        Uri.parse('$SERVER/lecturers'),
        headers: {
          'Accept': 'application/json',
          'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);

        setState(() {
          // Map lecturer names to their IDs
          lecturerMap = {
            for (var course in jsonResponse)
              course['name'].toString(): course['id'].toString()
          };
          lecturerNames = lecturerMap.keys.toList(); // List of lecturer names for dropdown
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load lecturers')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching lecturers: $error')),
      );
    }
  }

  Future<void> _fetchStudentGroups() async {
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
          studentGroupMap = {
            for (var group in jsonResponse)
              group['name'].toString(): group['id'].toString()
          };
          studentGroupNames = studentGroupMap.keys.toList(); // List of lecturer names for dropdown
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load student groups')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching student groups: $error')),
      );
    }
  }


  // Function to pick a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // Function to pick a time
  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        startTime = picked;
        endTime = null; // Reset end time when a new start time is selected
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    if (startTime == null) {
      // Alert the user that they need to select a start time first
      _showAlertDialog(context, 'Please select the start time first.');
      return;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: endTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      if (picked.hour < startTime!.hour ||
          (picked.hour == startTime!.hour && picked.minute <= startTime!.minute)) {
        // Alert if the selected end time is before or equal to the start time
        _showAlertDialog(context, 'End time cannot be before or the same as start time.');
      } else {
        setState(() {
          endTime = picked;
        });
      }
    }
  }

  Future<void> _handleLectureSubmission() async {
    // Check if any required fields are null
    if (selectedDate == null ||
        startTime == null ||
        endTime == null ||
        selectedCourseUnit == null ||
        selectedLecturer == null ||
        selectedStudentGroupId == null) {
      // Show alert if any fields are missing
      _showAlertDialog(context, 'Please fill in all fields.');
      return;
    } else {
      // Call the _addLecture function and wait for it to complete
      await _addLecture();

      // After the lecture is added, check if it was successful
      if (isLectureAdded != null && isLectureAdded == true && lectureId != null) {
        // Navigate to the ScannerPage if the lecture was added successfully
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScannerPage(
              lectureId: lectureId!,
            ),
          ),
        );
      } else {
        // Show an error message if the lecture failed to be added
        _showAlertDialog(context, 'Failed to add lecture.');
      }
    }
  }


  void clearSelections() {
    setState(() {
      selectedCourseUnit = null; // Clear course unit
      selectedLecturer = null;   // Clear lecturer
      selectedDate = null;       // Clear date
      startTime = null;          // Clear start time
      endTime = null;            // Clear end time
    });
  }

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Selection'),
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
          'Mark Attendance',
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
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
                      'Enter Course Details',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                        const Text(
                          "Course Unit Number:",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // DropdownSearch<String>(
                        //   key: dropDownKeyCourseUnit,
                        //   items: (filter, infiniteScrollProps) =>
                        //   ["PHY2222", "PHY12222", "PHY1234", "CSC1232","CHE2163"],
                        //   onChanged: (value) {
                        //     setState(() {
                        //       selectedCourseUnit = value; // Update selected course unit
                        //     });
                        //   },
                        //   selectedItem: selectedCourseUnit,
                        //   popupProps: PopupProps.menu(
                        //     showSearchBox: true,
                        //     fit: FlexFit.loose,
                        //     constraints: BoxConstraints(
                        //       maxHeight: MediaQuery.of(context).size.height * 0.5,
                        //       maxWidth: 308,
                        //     ),
                        //
                        //     containerBuilder: (context, popupWidget) {
                        //       return Container(
                        //         decoration: BoxDecoration(
                        //           color: const Color(0xFFE1FCE2), // Set the same background color
                        //           borderRadius: BorderRadius.circular(0), // Set the same border radius
                        //         ),
                        //         width: 308, // Set the width of the popup
                        //         child: popupWidget, // Return the actual popup content inside the styled container
                        //       );
                        //     },
                        //     searchFieldProps: TextFieldProps(
                        //       decoration: InputDecoration(
                        //         hintText: 'Search', // Set the placeholder text
                        //         border: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(25), // Rounded border for search box
                        //           borderSide: const BorderSide(
                        //             color: Colors.grey, // Border color for the search box
                        //           ),
                        //         ),
                        //         focusedBorder: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(25), // Rounded border when focused
                        //           borderSide: const BorderSide(
                        //             color: Colors.grey,
                        //           ),
                        //         ),
                        //         contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0), // Adjust padding
                        //       ),
                        //     ),
                        //   ),
                        //
                        //   decoratorProps: DropDownDecoratorProps(
                        //     decoration  : InputDecoration(
                        //       filled: true,
                        //       fillColor: const Color(0xFFE1FCE2), // Set background color
                        //       contentPadding: const EdgeInsets.symmetric(vertical: 0), // Adjust padding to fit height
                        //       enabledBorder: OutlineInputBorder(
                        //         borderRadius: BorderRadius.circular(25), // Rounded border
                        //         borderSide: const BorderSide(
                        //           color: Colors.transparent, // No border color
                        //         ),
                        //       ),
                        //       focusedBorder: OutlineInputBorder(
                        //         borderRadius: BorderRadius.circular(25), // Same rounded border when focused
                        //         borderSide: const BorderSide(
                        //           color: Colors.transparent,
                        //         ),
                        //       ),
                        //       border: OutlineInputBorder(
                        //         borderRadius: BorderRadius.circular(25),
                        //         borderSide: const BorderSide(
                        //           color: Colors.transparent,
                        //         ),
                        //       ),
                        //       // Set the label text and border behavior when label is focused
                        //     ),
                        //   ),
                        //
                        //   dropdownBuilder: (context, selectedItem) => Container(
                        //     alignment: Alignment.centerLeft,
                        //     width: 308, // Set width to 308
                        //     height: 35,  // Set height to 35
                        //     padding: const EdgeInsets.symmetric(horizontal: 10),
                        //     child: Text(
                        //       selectedItem ?? "Select an option",
                        //       style: const TextStyle(
                        //         fontFamily: 'Roboto',
                        //         fontWeight: FontWeight.w500,
                        //         fontSize: 14,
                        //         color: Colors.black, // You can customize the text style
                        //       ),
                        //     ),
                        //   ),
                        //
                        //
                        // ),
                        DropdownSearch<String>(
                          key: dropDownKeyCourseUnit,
                          // items: (filter, infiniteScrollProps) => _fetchCourses(),
                          items: (filter, infiniteScrollProps) => courseUnitNumbers, // Use the fetched course units
                          onChanged: (value) {
                            setState(() {
                              selectedCourseUnit = value; // Update selected course unit
                            });
                          },
                          selectedItem: selectedCourseUnit,
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
                              selectedItem ?? "Select an option",
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.black, // You can customize the text style
                              ),
                            ),
                          ),

                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Lecturer:",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownSearch<String>(
                          key: dropDownKeyLecturer,
                          items: (filter, infiniteScrollProps) => lecturerNames,
                          onChanged: (value) {
                            setState(() {
                              selectedLecturer = value; // Update selected lecturer
                              selectedLecturerId = lecturerMap[value!];
                            });
                          },
                          selectedItem: selectedLecturer,
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
                              selectedItem ?? "Select an option",
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.black, // You can customize the text style
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Student Group:",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownSearch<String>(
                          key: dropDownKeyStudentGroup,
                          items: (filter, infiniteScrollProps) => studentGroupNames,
                          onChanged: (value) {
                            setState(() {
                              selectedStudentGroupName = value; // Update selected lecturer
                              selectedStudentGroupId = studentGroupMap[value!];
                            });
                          },
                          selectedItem: selectedStudentGroupName,
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
                              selectedItem ?? "Select an option",
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.black, // You can customize the text style
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Date:",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _selectDate(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE1FCE2),

                          ),
                          child: Text(
                            selectedDate != null
                                ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                                : 'Select Date', // Display selected date or default text
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Time:",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "From",
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => _selectStartTime(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE1FCE2),
                                  ),
                                  child: Text(
                                    startTime != null
                                        ? "${startTime!.hourOfPeriod == 0 ? 12 : startTime!.hourOfPeriod}:${startTime!.minute.toString().padLeft(2, '0')} ${startTime!.period == DayPeriod.am ? 'AM' : 'PM'}"
                                        : 'Select Time', // Display selected time or default text
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),

                                ),

                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "To",
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => _selectEndTime(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE1FCE2),
                                  ),
                                  child: Text(
                                    endTime != null
                                        ? "${endTime!.hourOfPeriod == 0 ? 12 : endTime!.hourOfPeriod}:${endTime!.minute.toString().padLeft(2, '0')} ${endTime!.period == DayPeriod.am ? 'AM' : 'PM'}"
                                        : 'Select Time', // Display selected time or default text
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Generate Button
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

                                onPressed: _handleLectureSubmission,
                                child: const Text(
                                    'Scan',
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17,
                                        color: Colors.black
                                    )),
                              ),
                            ),
                            // Show Button
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
                                onPressed: clearSelections,
                                child: const Text(
                                    'Clear',
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17,
                                        color: Colors.black
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
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
