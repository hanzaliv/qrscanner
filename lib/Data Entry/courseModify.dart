import 'package:flutter/material.dart';
// import 'package:dropdown_search/dropdown_search.dart';
import 'dart:convert';  // For decoding JSON
import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// import 'courseModify.dart';
import 'course.dart';
import '../session_manager.dart';
import '../.env';
import '../menu.dart';



class ModifyCourses extends StatefulWidget {
  final String courseID;

  const ModifyCourses({super.key, required this.courseID});

  @override
  State<ModifyCourses> createState() => _ModifyCoursesState();
}

class _ModifyCoursesState extends State<ModifyCourses> {
  String? id;
  String? name;
  String? number;


  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController frontNameController = TextEditingController();
  TextEditingController frontNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    id = widget.courseID;
    idController.text = id!;

    findCourseById(widget.courseID);
  }

  Future<void> deleteCourse(String courseId) async {
    final sessionManager = SessionManager(); // Retrieve the singleton instance
    final url = Uri.parse('$SERVER/delete-course/$id');
    final headers = {
      'Content-Type': 'application/json',
      'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
    };

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        // print('Course deleted successfully');
      } else {
        // print('Failed to delete course: ${response.body}');
      }
    } catch (error) {
      // print('Error deleting course: $error');
    }
  }

  Future<void> findCourseById(String courseId) async {

    final sessionManager = SessionManager(); // Retrieve the singleton instance
    final url = Uri.parse('$SERVER/get-course/$id');
    final headers = {
      'Content-Type': 'application/json',
      'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          // Update your state with the course details
          name = jsonResponse['course_unit_name'];
          number = jsonResponse['course_unit_number'];
          nameController.text = name!;
          numberController.text = number!;
          frontNumberController.text = number!;
          frontNameController.text = name!;

          // print('Course fetched successfully');
          // print('Course Name: $name');
          // print('Course Number: $number');

        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch course: ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching course: $error')),
      );
    }
  }

  Future<void> updateCourseById(String id, String name, String number) async {
    final sessionManager = SessionManager(); // Retrieve the singleton instance
    final url = Uri.parse('$SERVER/update-course/$id');
    final headers = {
      'Content-Type': 'application/json',
      'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
    };
    final body = jsonEncode({'course_unit_name': name, 'course_unit_number': number});

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // print('Course updated successfully');
      } else {
        // print('Failed to update course: ${response.body}');
      }
    } catch (error) {
      // print('Error updating course: $error');
    }
  }


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
                                'Details',
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
                                'Course ID: ',
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
                                  enabled: false, // Non-editable
                                  controller: TextEditingController(text: id),
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                    border: InputBorder.none,
                                  ),
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
                                'Course Name: ',
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
                                  enabled: false, // Non-editable
                                  controller: frontNameController,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                    border: InputBorder.none,
                                  ),
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
                                'Course Unit Number ',
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
                                  enabled: false, // Non-editable
                                  controller: frontNumberController,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
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
                                  // Set current values in controllers before showing the dialog
                                  nameController.text = name!;
                                  numberController.text = number!;

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Modify Course'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: nameController,
                                              decoration: const InputDecoration(
                                                labelText: 'Course Name',
                                              ),
                                            ),
                                            TextField(
                                              controller: numberController,
                                              decoration: const InputDecoration(
                                                labelText: 'Course Email',
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              nameController.clear();
                                              numberController.clear();
                                            },
                                            child: const Text('Clear'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              if (nameController.text.isEmpty || numberController.text.isEmpty) {
                                                showTopSnackBar(context, 'All fields are required.', Colors.red); // Red snackbar for error
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (BuildContext context) {
                                                    return const AlertDialog(
                                                      title: Text('Updating'),
                                                      content: SizedBox(
                                                          height: 100,
                                                          child: Center(child: CircularProgressIndicator())),
                                                    );
                                                  },
                                                );

                                                try {
                                                  await updateCourseById(id!, nameController.text, numberController.text);
                                                  await findCourseById(widget.courseID);
                                                  Navigator.pop(context); // Close the progress dialog
                                                  Navigator.pop(context); // Close the modify Course screen
                                                  showTopSnackBar(context, 'Course details updated successfully.', Colors.green); // Green snackbar for success
                                                } catch (error) {
                                                  await findCourseById(widget.courseID);
                                                  Navigator.pop(context); // Close the progress dialog
                                                  Navigator.pop(context);
                                                  showTopSnackBar(context, 'Failed to update Course: $error', Colors.red); // Red snackbar for error
                                                }
                                              }
                                            },
                                            child: const Text('Save'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Text(
                                    'Modify',
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
                                  backgroundColor: const Color(0xFFFA8D7E), // Button background color
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(color: Colors.white, width: 2),
                                    borderRadius: BorderRadius.circular(15), // Border radius of 15
                                  ),

                                ),

                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirm Deletion'),
                                        content: const Text('Are you sure you want to delete this Course?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(); // Close the dialog
                                            },
                                            child: const Text('No'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.of(context).pop(); // Close the confirmation dialog
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (BuildContext context) {
                                                  return const AlertDialog(
                                                    title: Text('Deleting Course'),
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
                                                await deleteCourse(widget.courseID);
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => const Course(),
                                                  ),
                                                );
                                                showTopSnackBar(context, 'Course deleted successfully', Colors.green);
                                              } catch (error) {
                                                Navigator.of(context).pop(); // Close the deleting dialog
                                                showTopSnackBar(context, "Failed to Delete Course", Colors.red);
                                              }
                                            },
                                            child: const Text('Yes'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Text(
                                    'Delete',
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17,
                                        color: Colors.white
                                    )),
                              ),
                            ),

                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
