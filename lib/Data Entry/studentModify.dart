import 'package:flutter/material.dart';
import 'dart:convert';  // For decoding JSON
import 'package:http/http.dart' as http;

import 'student.dart';
import '../session_manager.dart';
import '../menu.dart';
import '../.env';

class ModifyStudent extends StatefulWidget {
  final String name;
  final String id;
  // final String email;

  const ModifyStudent({
    super.key,
    required this.name,
    required this.id,
    // required this.email,
  });

  @override
  State<ModifyStudent> createState() => _ModifyStudentState();
}

class _ModifyStudentState extends State<ModifyStudent> {

  String? id;
  String? name;
  String? email;
  String? phoneNumber;
  String? regNo;


  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController regNoController = TextEditingController();
  TextEditingController frontNameController = TextEditingController();
  TextEditingController frontEmailController = TextEditingController();
  TextEditingController frontPhoneController = TextEditingController();
  TextEditingController frontRegNoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    id = widget.id;
    name = widget.name;
    idController.text = id!;

    _findStudentById();
  }

  Future<void> deleteStudent(String id) async {
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
        // print('student deleted successfully by ID');
      } else {
        // print('Failed to delete student by ID: ${response.body}');
      }
    } catch (error) {
      // print('Error deleting student by ID: $error');
    }
  }

  Future<void> updateStudentById(String id, String name, String email, String phone, String regNo) async {
    final sessionManager = SessionManager(); // Retrieve the singleton instance
    final url = Uri.parse('$SERVER/update-student/$id');
    final headers = {
      'Content-Type': 'application/json',
      'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
    };
    final body = jsonEncode({
      'name': name,
      'email': email,
      'phone': phone,
      'sc_number': regNo
    });

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // print('student updated successfully');
      } else {
        // print('Failed to update student: ${response.body}');
      }
    } catch (error) {
      // print('Error updating student: $error');
    }
  }

  Future<void> _findStudentById() async {
    try {
      final sessionManager = SessionManager(); // Retrieve the singleton instance

      // Prepare the request body
      var body = jsonEncode({'id': id!});

      final response = await http.post(
        Uri.parse('$SERVER/single-student'),
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
          if(jsonResponse['sc_number'] == null) {
            regNo = "null";
          } else {
            regNo = jsonResponse['sc_number'];
          }
          nameController.text = name!;
          emailController.text = email!;
          phoneNumberController.text = phoneNumber!;
          regNoController.text = regNo!;
          frontNameController = nameController;
          frontEmailController = emailController;
          frontPhoneController = phoneNumberController;
          frontRegNoController = regNoController;
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
                                'Student ID: ',
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
                                'Student Register Number: ',
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
                                  controller: frontRegNoController,
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
                                'Student Email: ',
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
                                'Student Phone: ',
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
                                  regNoController.text = regNo!;

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Modify Student'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: nameController,
                                              decoration: const InputDecoration(
                                                labelText: 'Student Name',
                                              ),
                                            ),
                                            TextField(
                                              controller: regNoController,
                                              decoration: const InputDecoration(
                                                labelText: 'Student Register Number',
                                              ),
                                            ),
                                            TextField(
                                              controller: emailController,
                                              decoration: const InputDecoration(
                                                labelText: 'Student Email',
                                              ),
                                            ),
                                            TextField(
                                              controller: phoneNumberController,
                                              decoration: const InputDecoration(
                                                labelText: 'Student Phone Number',
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
                                              regNoController.clear();
                                            },
                                            child: const Text('Clear'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              if (nameController.text.isEmpty || emailController.text.isEmpty || phoneNumberController.text.isEmpty || regNoController.text.isEmpty) {
                                                showTopSnackBar(context, 'All fields are required.', Colors.red); // Red snackbar for error
                                              } else if (!RegExp(r'^\d+$').hasMatch(phoneNumberController.text)) {
                                                showTopSnackBar(context, 'Phone number must contain only digits.', Colors.red); // Red snackbar for error
                                                showTopSnackBar(context, 'Invalid email format.', Colors.red); // Red snackbar for error
                                              }else if(!RegExp(r'^[A-Za-z]{2}/20\d{2}/\d{5}$').hasMatch(regNoController.text)) {
                                                showTopSnackBar(context, 'Invalid Register Number format.', Colors.red); // Red snackbar for error

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
                                                  await updateStudentById(id!, nameController.text, emailController.text, phoneNumberController.text, regNoController.text);
                                                  await _findStudentById();
                                                  Navigator.pop(context); // Close the progress dialog
                                                  Navigator.pop(context); // Close the modify Assistant screen
                                                  showTopSnackBar(context, 'Assistant details updated successfully.', Colors.green); // Green snackbar for success
                                                } catch (error) {
                                                  _findStudentById(); // Reset the fields to the original values
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
                                        content: const Text('Are you sure you want to delete this student?'),
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
                                                    title: Text('Deleting student'),
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
                                                await deleteStudent(id!);
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => const Student(),
                                                  ),
                                                );
                                                showTopSnackBar(context, 'Assistant deleted successfully', Colors.green);
                                                // Close the modify Assistant screen
                                              } catch (error) {
                                                Navigator.of(context).pop(); // Close the deleting dialog
                                                showTopSnackBar(context, "Failed to Delete Assistant", Colors.red);
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
