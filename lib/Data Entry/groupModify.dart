import 'package:flutter/material.dart';
import 'dart:convert';  // For decoding JSON
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';

import '../session_manager.dart';
import '../.env';
class ModifyGroup extends StatefulWidget {

  final String selectedId;
  final String selectedName;

  const ModifyGroup({super.key, required this.selectedId, required this.selectedName});

  @override
  State<ModifyGroup> createState() => _ModifyGroupState();
}

class _ModifyGroupState extends State<ModifyGroup> {
  String? id;
  String? name;
  String? selectedStudentId;

  final dropDownKeyFind = GlobalKey<DropdownSearchState>();

  Map<String, Map<String, String>> studentMap = {}; // To store the name and ID mapping
  List<String> studentId = []; // To store only the ids for the dropdown
  List<Map<String, String>> studentsInGroup = [];

  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController frontNameController = TextEditingController();
  TextEditingController studentNameController = TextEditingController();
  TextEditingController studentRegNumController = TextEditingController();


  @override
  void initState() {
    super.initState();
    id = widget.selectedId;
    idController.text = id!;

    _findGroupById();
    _fetchStudents();
    getStudentsByGroup(id!);
  }


  Future<void> _findGroupById() async {
    try {
      final sessionManager = SessionManager(); // Retrieve the singleton instance

      // Prepare the request body
      var body = jsonEncode({'id': id!});

      final response = await http.post(
        Uri.parse('$SERVER/get-group-name'),
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
          nameController.text = name!;
          frontNameController.text = name!;
        });
      } else {
        name = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No Matching Group Found')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching Group: $error')),
      );
    }
  }

  Future<void> updateGroupById(String id, String name) async {
    final sessionManager = SessionManager(); // Retrieve the singleton instance
    final url = Uri.parse('$SERVER/modify-student-group');
    final headers = {
      'Content-Type': 'application/json',
      'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
    };
    final body = jsonEncode({
      'group_id': id,
      'new_name': name
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('Group updated successfully');
      } else {
        print('Failed to update Group: ${response.body}');
      }
    } catch (error) {
      print('Error updating Group: $error');
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
          // Map student sc_number to a map containing id and name
          studentMap = {
            for (var student in jsonResponse)
              student['sc_number'].toString(): {
                'id': student['id'].toString(),
                'name': student['name'].toString()
              }
          };
          studentId = studentMap.keys.toList(); // List of student sc_numbers for dropdown
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

  Future<void> addStudentToGroup(String studentUserId, String groupId) async {
  final sessionManager = SessionManager(); // Retrieve the singleton instance
  final url = Uri.parse('$SERVER/add-student-to-group');
  final headers = {
    'Content-Type': 'application/json',
    'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
  };
  final body = jsonEncode({
    'student_user_id': studentUserId,
    'group_id': groupId,
  });

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print('Student added to group successfully');
    } else {
      print('Failed to add student to group: ${response.body}');
    }
  } catch (error) {
    print('Error adding student to group: $error');
  }
}

  Future<void> getStudentsByGroup(String groupId) async {
  final sessionManager = SessionManager(); // Retrieve the singleton instance
  final url = Uri.parse('$SERVER/get-students-by-group');
  final headers = {
    'Content-Type': 'application/json',
    'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
  };
  final body = jsonEncode({'group_id': groupId});

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);

      studentsInGroup = jsonResponse.map((student) {
        return {
          'sc_number': student['sc_number'].toString(),
          'id': student['id'].toString(),
          'name': student['name'].toString(),
        };
      }).toList();
print('Students in group: $studentsInGroup');
      // Handle the response data as needed
      print('Students in group: $jsonResponse');
    } else {
      print('Failed to get students by group: ${response.body}');
    }
  } catch (error) {
    print('Error getting students by group: $error');
  }
}

  Future<void> deleteStudentGroup(String groupId) async {
    final sessionManager = SessionManager(); // Retrieve the singleton instance
    final url = Uri.parse('$SERVER/delete-student-group');
    final headers = {
      'Content-Type': 'application/json',
      'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
    };
    final body = jsonEncode({'group_id': groupId});

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print('Student group deleted successfully');
    } else {
      print('Failed to delete student group: ${response.body}');
    }
  } catch (error) {
    print('Error deleting student group: $error');
  }
}

  Future<void> removeStudentFromGroup(String studentUserId) async {
    final sessionManager = SessionManager(); // Retrieve the singleton instance
    final url = Uri.parse('$SERVER/remove-student-from-group');
    final headers = {
      'Content-Type': 'application/json',
      'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
    };
    final body = jsonEncode({
      'student_user_id': studentUserId,
      'group_id': id!,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('Student removed from group successfully');
      } else {
        print('Failed to remove student from group: ${response.body}');
      }
    } catch (error) {
      print('Error removing student from group: $error');
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
                                'Group ID: ',
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
                                'Group Name: ',
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

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Modify Group'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: nameController,
                                              decoration: const InputDecoration(
                                                labelText: 'Group Name',
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              nameController.clear();
                                            },
                                            child: const Text('Clear'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              if (nameController.text.isEmpty) {
                                                showTopSnackBar(context, 'All fields are required.', Colors.red); // Red snackbar for error
                                              }  else {
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
                                                  await updateGroupById(id!, nameController.text);
                                                  await _findGroupById();
                                                  Navigator.pop(context); // Close the progress dialog
                                                  Navigator.pop(context); // Close the modify Group screen
                                                  showTopSnackBar(context, 'Group details updated successfully.', Colors.green); // Green snackbar for success
                                                } catch (error) {
                                                  _findGroupById(); // Reset the fields to the original values
                                                  Navigator.pop(context); // Close the progress dialog
                                                  Navigator.pop(context);
                                                  showTopSnackBar(context, 'Failed to update Group: $error', Colors.red); // Red snackbar for error
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
                                        content: const Text('Are you sure you want to delete this Group?'),
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
                                                    title: Text('Deleting Group'),
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
                                                await deleteStudentGroup(id!);
                                                Navigator.pop(context);
                                                Navigator.pop(context); // Close the modify Group screen
                                                showTopSnackBar(context, 'Group deleted successfully', Colors.green);
                                                // Close the modify Group screen
                                              } catch (error) {
                                                Navigator.of(context).pop(); // Close the deleting dialog
                                                showTopSnackBar(context, "Failed to Delete Group", Colors.red);
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
                  SizedBox(height: 20),
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
                                'Add Students',
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
                                'Student Number: ',
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
                                  controller: studentRegNumController,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    if (studentMap.containsKey(value)) {
                                      setState(() {
                                        studentNameController.text = studentMap[value]!['name']!;
                                        print(studentNameController.text);
                                        print(studentMap[value]!['name']);
                                        selectedStudentId = studentMap[value]!['id']!;
                                      });
                                    } else {
                                      setState(() {
                                        studentNameController.clear();
                                        selectedStudentId = null;
                                      });
                                    }
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
                                  enabled: false,
                                  controller: studentNameController,
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
                                onPressed: () async {
                                  if (!studentId.map((e) => e.toLowerCase()).contains(studentRegNumController.text.toLowerCase())) {
                                    showTopSnackBar(context, 'Invalid student number', Colors.red);
                                  } else if (studentsInGroup.any((student) => student['sc_number']!.toLowerCase() == studentRegNumController.text.toLowerCase())) {
                                    showTopSnackBar(context, 'Student already in the group', Colors.red);
                                  } else {
                                    try {
                                      await addStudentToGroup(selectedStudentId!, id!);
                                      showTopSnackBar(context, 'Student added to group successfully', Colors.green);
                                    } catch (error) {
                                      showTopSnackBar(context, 'Failed to add student to group: $error', Colors.red);
                                    }
                                  }
                                },
                                child: const Text(
                                  'Add',
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
                                  backgroundColor: const Color(0xFF88C98A), // Button background color
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(color: Colors.white, width: 2),
                                    borderRadius: BorderRadius.circular(15), // Border radius of 15
                                  ),
                                ),
                                onPressed: () async {
                                  await getStudentsByGroup(id!);
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setState) {
                                          return AlertDialog(
                                            title: Text(
                                              'Students in Group ${widget.selectedName}',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                            content: SizedBox(
                                              width: double.maxFinite,
                                              child: Column(
                                                children: [
                                                  const Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        flex: 4,
                                                        child: Text(
                                                          'Student Number',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontFamily: 'Roboto',
                                                            fontWeight: FontWeight.w500,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 4,
                                                        child: Text(
                                                          'Name',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontFamily: 'Roboto',
                                                            fontWeight: FontWeight.w500,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                          'Action',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontFamily: 'Roboto',
                                                            fontWeight: FontWeight.w500,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Divider(),
                                                  Expanded(
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: studentsInGroup.length,
                                                      itemBuilder: (context, index) {
                                                        return StudentRow(
                                                          scNumber: studentsInGroup[index]['sc_number']!,
                                                          name: studentsInGroup[index]['name']!,
                                                          onDelete: () async {
                                                            showDialog(
                                                              context: context,
                                                              barrierDismissible: false,
                                                              builder: (BuildContext context) {
                                                                return const AlertDialog(
                                                                  title: Text('Deleting Student'),
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
                                                              await removeStudentFromGroup(studentsInGroup[index]['id']!);

                                                              // Remove the student from the list locally
                                                              setState(() {
                                                                studentsInGroup.removeAt(index);
                                                              });

                                                              Navigator.pop(context); // Close the progress dialog
                                                              showTopSnackBar(context, 'Student removed from group successfully', Colors.green);
                                                            } catch (error) {
                                                              Navigator.pop(context); // Close the progress dialog
                                                              showTopSnackBar(context, 'Failed to remove student from group: $error', Colors.red);
                                                            }
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
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
                                  'View All',
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
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );  }
}

class StudentRow extends StatelessWidget {
  final String scNumber;
  final String name;
  final VoidCallback onDelete;

  const StudentRow({
    Key? key,
    required this.scNumber,
    required this.name,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                scNumber,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  const SizedBox(width: 5,),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: onDelete,
                    ),
                  )

                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
