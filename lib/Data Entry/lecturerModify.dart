import 'package:flutter/material.dart';
import 'dart:convert';  // For decoding JSON
import 'package:http/http.dart' as http;

import '../session_manager.dart';
import '../.env';
import '../menu.dart';


class ModifyLecturer extends StatefulWidget {
  final String name;
  final String id;
  // final String email;

  const ModifyLecturer({
    super.key,
    required this.name,
    required this.id,
    // required this.email,
  });

  @override
  State<ModifyLecturer> createState() => _ModifyLecturerState();
}

class _ModifyLecturerState extends State<ModifyLecturer> {

  String? id;
  String? name;
  String? email;
  String? phoneNumber;


  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController frontNameController = TextEditingController();
  TextEditingController frontEmailController = TextEditingController();
  TextEditingController frontPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    id = widget.id;
    name = widget.name;
    idController.text = id!;

    _findLecturesById();
  }

  Future<void> deleteLecturer(String id) async {
  final sessionManager = SessionManager(); // Retrieve the singleton instance
  final url = Uri.parse('$SERVER/delete-by-id');
  final headers = {
    'Content-Type': 'application/json',
    'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
  };
  final body = jsonEncode({'id': id});

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 201) {
      // print('Lecturer deleted successfully by ID');
    } else {
      // print('Failed to delete lecturer by ID: ${response.body}');
    }
  } catch (error) {
    // print('Error deleting lecturer by ID: $error');
  }
}

  Future<void> updateLecturerById(String id, String name, String email, String phone) async {
  final sessionManager = SessionManager(); // Retrieve the singleton instance
  final url = Uri.parse('$SERVER/update-lecturer/$id');
  final headers = {
    'Content-Type': 'application/json',
    'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
  };
  final body = jsonEncode({
    'name': name,
    'email': email,
    'phone': phone,
  });

  try {
    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // print('Lecturer updated successfully');
    } else {
      // print('Failed to update lecturer: ${response.body}');
    }
  } catch (error) {
    // print('Error updating lecturer: $error');
  }
}

  Future<void> _findLecturesById() async {
    try {
      final sessionManager = SessionManager(); // Retrieve the singleton instance

      // Prepare the request body
      var body = jsonEncode({'id': id!});

      final response = await http.post(
        Uri.parse('$SERVER/single-lecturer'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json', // Indicate that the body is JSON
          'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
        },
        body: body, // Send the sc_number in the request body
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);

        setState(() {
          // Extract 'name' from the response
          name = jsonResponse['name'];
          email = jsonResponse['email'];
          phoneNumber = jsonResponse['phone'];
          nameController.text = name!;
          emailController.text = email!;
          phoneNumberController.text = phoneNumber!;
          frontNameController.text = name!;
          frontEmailController.text = email!;
          frontPhoneController.text = phoneNumber!;
        });
      } else {
        name = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No Matching Student Found')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching student: $error')),
      );
    }
  }


  List<Map<String, dynamic>> courses = [
    {'courseNumber': 'PHY2222', 'courseName': 'Electronics', 'selected': false},
    {'courseNumber': 'CS1101', 'courseName': 'Introduction to Computing', 'selected': false},
    {'courseNumber': 'MAT2201', 'courseName': 'Discrete Mathematics', 'selected': false},
    {'courseNumber': 'ENG2202', 'courseName': 'Technical Writing', 'selected': false},
    {'courseNumber': 'PHY2233', 'courseName': 'Quantum Mechanics', 'selected': false},
    {'courseNumber': 'CS3102', 'courseName': 'Algorithms and Data Structures', 'selected': false},
    {'courseNumber': 'BIO1301', 'courseName': 'Molecular Biology', 'selected': false},
    {'courseNumber': 'CHEM2211', 'courseName': 'Organic Chemistry', 'selected': false},
    {'courseNumber': 'CS1201', 'courseName': 'Web Development Basics', 'selected': false},
    {'courseNumber': 'CS3303', 'courseName': 'Machine Learning', 'selected': false},
  ];

  void showTopSnackBar(BuildContext context, String message, Color color) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0,
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color,
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
                                'Lecturer Email: ',
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
                                  controller: frontEmailController,
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
                                'Lecturer Phone: ',
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
                                  controller: frontPhoneController,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
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
                                  emailController.text = email!;
                                  phoneNumberController.text = phoneNumber!;

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Modify Lecturer'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: nameController,
                                              decoration: const InputDecoration(
                                                labelText: 'Lecturer Name',
                                              ),
                                            ),
                                            TextField(
                                              controller: emailController,
                                              decoration: const InputDecoration(
                                                labelText: 'Lecturer Email',
                                              ),
                                            ),
                                            TextField(
                                              controller: phoneNumberController,
                                              decoration: const InputDecoration(
                                                labelText: 'Lecturer Phone Number',
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              nameController.clear();
                                              emailController.clear();
                                              phoneNumberController.clear();
                                            },
                                            child: const Text('Clear'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              if (nameController.text.isEmpty || emailController.text.isEmpty || phoneNumberController.text.isEmpty) {
                                                showTopSnackBar(context, 'All fields are required.', Colors.red); // Red snackbar for error
                                              } else if (!RegExp(r'^\d+$').hasMatch(phoneNumberController.text)) {
                                                showTopSnackBar(context, 'Phone number must contain only digits.', Colors.red); // Red snackbar for error
                                              } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text)) {
                                                showTopSnackBar(context, 'Invalid email format.', Colors.red); // Red snackbar for error
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
                                                  await updateLecturerById(id!, nameController.text, emailController.text, phoneNumberController.text);
                                                  await _findLecturesById(); // Update the fields with the new values
                                                  Navigator.pop(context); // Close the progress dialog
                                                  Navigator.pop(context); // Close the modify Assistant screen
                                                  showTopSnackBar(context, 'Assistant details updated successfully.', Colors.green); // Green snackbar for success
                                                } catch (error) {
                                                  _findLecturesById(); // Reset the fields to the original values
                                                  Navigator.pop(context); // Close the progress dialog
                                                  Navigator.pop(context);
                                                  showTopSnackBar(context, 'Failed to update assistant: $error', Colors.red); // Red snackbar for error
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
                                        content: const Text('Are you sure you want to delete this lecturer?'),
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
                                                    title: Text('Deleting Lecturer'),
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
                                                await deleteLecturer(id!);
                                                Navigator.of(context).pop(); // Close the deleting dialog
                                                Navigator.pop(context);
                                                showTopSnackBar(context, 'Lecturer deleted successfully', Colors.green);
                                                // Close the modify lecturer screen
                                              } catch (error) {
                                                Navigator.of(context).pop(); // Close the deleting dialog
                                                showTopSnackBar(context, "Failed to Delete Lecturer", Colors.red);
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
                  //lecturer courses part
                  // const SizedBox(height: 20,),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  //   margin: const EdgeInsets.symmetric(horizontal: 20),
                  //   decoration: BoxDecoration(
                  //     border: Border.all(
                  //       color: const Color(0xFF88C98A),
                  //       width: 2,
                  //     ),
                  //     borderRadius: BorderRadius.circular(40),
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       const SizedBox(height: 10),
                  //       const Row(
                  //         children: [
                  //           Expanded(
                  //             child: Divider(
                  //               thickness: 1,
                  //               color: Color(0xFF88C98A),
                  //             ),
                  //           ),
                  //           Padding(
                  //             padding: EdgeInsets.symmetric(horizontal: 8.0),
                  //             child: Text(
                  //               'Courses',
                  //               style: TextStyle(
                  //                 fontSize: 16,
                  //                 fontFamily: 'Roboto',
                  //                 fontWeight: FontWeight.w500,
                  //                 color: Color(0xFF88C98A),
                  //               ),
                  //             ),
                  //           ),
                  //           Expanded(
                  //             child: Divider(
                  //               thickness: 1,
                  //               color: Color(0xFF88C98A),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       const SizedBox(height: 10),
                  //
                  //       // List of courses
                  //       Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: courses.map((course) {
                  //           return Padding(
                  //             padding: const EdgeInsets.only(bottom: 8.0),
                  //             child: Text(
                  //               '${course['courseNumber']} - ${course['courseName']}',
                  //               style: const TextStyle(
                  //                 fontSize: 16,
                  //                 fontFamily: 'Roboto',
                  //                 fontWeight: FontWeight.w500,
                  //                 color: Colors.black,
                  //               ),
                  //             ),
                  //           );
                  //         }).toList(),
                  //       ),
                  //
                  //       const SizedBox(height: 10), // Add spacing between the list and the button
                  //
                  //       // Remove Courses Button
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           SizedBox(
                  //             width: 120,
                  //             height: 40,
                  //             child: ElevatedButton(
                  //               style: ElevatedButton.styleFrom(
                  //                 backgroundColor: const Color(0xFF88C98A), // Button background color
                  //                 shape: RoundedRectangleBorder(
                  //                   side: const BorderSide(color: Colors.white, width: 2),
                  //                   borderRadius: BorderRadius.circular(15), // Border radius of 15
                  //                 ),
                  //
                  //               ),
                  //
                  //               onPressed: () {},
                  //               child: const Text(
                  //                   'Add',
                  //                   style: TextStyle(
                  //                       fontFamily: 'Roboto',
                  //                       fontWeight: FontWeight.w500,
                  //                       fontSize: 17,
                  //                       color: Colors.white
                  //                   )),
                  //             ),
                  //           ),
                  //           SizedBox(
                  //             height: 40,
                  //             child: ElevatedButton(
                  //               style: ElevatedButton.styleFrom(
                  //                 backgroundColor: const Color(0xFFFA8D7E), // Button background color
                  //                 shape: RoundedRectangleBorder(
                  //                   side: const BorderSide(color: Colors.white, width: 2),
                  //                   borderRadius: BorderRadius.circular(15), // Border radius of 15
                  //                 ),
                  //               ),
                  //               onPressed: () {
                  //                 showDialog(
                  //                   context: context,
                  //                   builder: (BuildContext context) {
                  //                     return StatefulBuilder(
                  //                       builder: (BuildContext context, StateSetter setStateDialog) {
                  //                         return AlertDialog(
                  //                           title: const Text('Remove Courses'),
                  //                           content: SizedBox(
                  //                             height: 300,
                  //                             width: 300,
                  //                             child: ListView(
                  //                               children: courses.map((course) {
                  //                                 return CheckboxListTile(
                  //                                   title: Text('${course['courseNumber']} - ${course['courseName']}'),
                  //                                   value: course['selected'],
                  //                                   onChanged: (bool? value) {
                  //                                     setStateDialog(() {
                  //                                       course['selected'] = value!;
                  //                                     });
                  //                                   },
                  //                                 );
                  //                               }).toList(),
                  //                             ),
                  //                           ),
                  //                           actions: [
                  //                             TextButton(
                  //                               onPressed: () {
                  //                                 setState(() {
                  //                                   // Update the parent widget
                  //                                   courses.removeWhere((course) => course['selected']);
                  //                                 });
                  //                                 Navigator.pop(context);
                  //                               },
                  //                               child: const Text('Delete Selected'),
                  //                             ),
                  //                             TextButton(
                  //                               onPressed: () {
                  //                                 Navigator.pop(context);
                  //                               },
                  //                               child: const Text('Close'),
                  //                             ),
                  //                           ],
                  //                         );
                  //                       },
                  //                     );
                  //                   },
                  //                 );
                  //               },
                  //
                  //               child: const Text(
                  //                 'Remove',
                  //                 style: TextStyle(
                  //                   fontFamily: 'Roboto',
                  //                   fontWeight: FontWeight.w500,
                  //                   fontSize: 17,
                  //                   color: Colors.white,
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
