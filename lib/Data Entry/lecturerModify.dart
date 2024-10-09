import 'package:flutter/material.dart';

class ModifyLecturer extends StatefulWidget {
  const ModifyLecturer({super.key});

  @override
  State<ModifyLecturer> createState() => _ModifyLecturerState();
}

class _ModifyLecturerState extends State<ModifyLecturer> {

  String id = 'Test';
  String name = 'Test';

  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    idController.text = id;
    nameController.text = name;
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
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: Container(
          //     height: MediaQuery.of(context).size.height * 0.3,
          //     decoration: const BoxDecoration(
          //       color: Color(0xFFC7FFC9),
          //       borderRadius: BorderRadius.only(
          //         topLeft: Radius.circular(30),
          //         topRight: Radius.circular(30),
          //       ),
          //     ),
          //   ),
          // ),
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
                                  controller: TextEditingController(text: name),
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
                                  idController.text = id;
                                  nameController.text = name;

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Modify Lecturer'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: idController,
                                              decoration: const InputDecoration(
                                                labelText: 'Lecturer ID',
                                              ),
                                            ),
                                            TextField(
                                              controller: nameController,
                                              decoration: const InputDecoration(
                                                labelText: 'Lecturer Name',
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              idController.clear();
                                              nameController.clear();
                                            },
                                            child: const Text('Clear'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              if (idController.text.isEmpty || nameController.text.isEmpty) {
                                                showTopSnackBar(context, 'Both fields are required.', Colors.red); // Red snackbar for error
                                              } else {
                                                setState(() {
                                                  // Update the values
                                                  id = idController.text;
                                                  name = nameController.text;
                                                });
                                                showTopSnackBar(context, 'Lecturer details updated successfully.', Colors.green); // Green snackbar for success
                                                Navigator.pop(context);
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
                  const SizedBox(height: 20,),
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
                                'Courses',
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
                        const SizedBox(height: 10),

                        // List of courses
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: courses.map((course) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                '${course['courseNumber']} - ${course['courseName']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 10), // Add spacing between the list and the button

                        // Remove Courses Button
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

                                onPressed: () {},
                                child: const Text(
                                    'Add',
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17,
                                        color: Colors.white
                                    )),
                              ),
                            ),
                            SizedBox(
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
                                      return StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setStateDialog) {
                                          return AlertDialog(
                                            title: const Text('Remove Courses'),
                                            content: SizedBox(
                                              height: 300,
                                              width: 300,
                                              child: ListView(
                                                children: courses.map((course) {
                                                  return CheckboxListTile(
                                                    title: Text('${course['courseNumber']} - ${course['courseName']}'),
                                                    value: course['selected'],
                                                    onChanged: (bool? value) {
                                                      setStateDialog(() {
                                                        course['selected'] = value!;
                                                      });
                                                    },
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    // Update the parent widget
                                                    courses.removeWhere((course) => course['selected']);
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Delete Selected'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Close'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                },

                                child: const Text(
                                  'Remove',
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
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
