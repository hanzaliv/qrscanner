import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import '../.env';
import '../session_manager.dart';
import '../menu.dart';


class DetailedAttendancePage extends StatefulWidget {
  final String lecId;
  final String groupId;

  const DetailedAttendancePage({super.key, required this.lecId, required this.groupId});

  @override
  State<DetailedAttendancePage> createState() => _DetailedAttendancePageState();
}

class _DetailedAttendancePageState extends State<DetailedAttendancePage> {

  List<Map<String, dynamic>> attendanceDetails = [];
  List<Map<String, String>> studentsInGroup = [];
  List<Map<String, dynamic>> allStudentsWithAttendance = [];
  bool isLoading = false;
  String? errorMessage;
  String? lecId;

  @override
  void initState(){
    super.initState();
    lecId = widget.lecId;
    initFunc();
  }


  Future<void> initFunc() async{
    await getStudentsByGroup(widget.groupId);
    await getLectureAttendance(int.parse(widget.lecId));
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


  Future<void> getLectureAttendance(int lecId) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final String apiUrl = "$SERVER/get-attendance";

    try {
      final sessionManager = SessionManager(); // Retrieve the singleton instance

      var body = jsonEncode({'lec_id': lecId});

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        setState(() {
          attendanceDetails = List<Map<String, dynamic>>.from(responseData['attendanceDetails']);
          allStudentsWithAttendance = studentsInGroup.map((student) {
            bool isPresent = attendanceDetails.any((attendance) => attendance['sc_number'] == student['sc_number']);
            return {
              'sc_number': student['sc_number'],
              'name': student['name'],
              'isPresent': isPresent,
            };
          }).toList();
        });
      } else {
        setState(() {
          errorMessage = "Error: ${response.body}";
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = "Error fetching attendance: $error";
      });
      // print(errorMessage);
    } finally {
      setState(() {
        isLoading = false;
      });
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
        // Handle the response data as needed
        // print('Students in group: $jsonResponse');
      } else {
        // print('Failed to get students by group: ${response.body}');
      }
    } catch (error) {
      // print('Error getting students by group: $error');
    }
  }

  Future<void> exportAttendanceToExcel(BuildContext context) async {
    try {
      // Request storage permission
      var status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        // If permission is denied, show an error message
        showTopSnackBar(context, 'Storage permission denied', Colors.red);
        return;
      }

      // Create a new Excel document
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Attendance'];

      // Add header row
      sheetObject.appendRow(['Student Number', 'Name', 'Attendance']);

      // Add data rows
      for (var student in allStudentsWithAttendance) {
        sheetObject.appendRow([
          student['sc_number'],
          student['name'],
          student['isPresent'] ? '1' : '0'
        ]);
      }

      // Define the Downloads folder path
      const String downloadsDir = '/storage/emulated/0/Download';
      final String filePath = '$downloadsDir/attendance_lec_$lecId.xlsx';

      // Save the Excel file in the Downloads folder
      final File file = File(filePath);
      await file.writeAsBytes(excel.encode()!);

      // Show a success message to the user
      showTopSnackBar(context, 'Attendance exported to Downloads', Colors.green);
    } catch (error) {
      // Handle any errors that occur during the export process
      showTopSnackBar(context, 'Failed to export attendance: $error', Colors.red);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent the view from resizing when the keyboard appears
      appBar: AppBar(
        title: const Text(
          'Recorded Attendance',
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
      drawer: const Menu(),
      body: Column(
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (errorMessage != null)
            Center(child: Text(errorMessage!))
          else if (attendanceDetails.isEmpty)
              const Center(child: Text("No attendance data available"))
            else ...[
                TextButton(
                  onPressed: () {
                    exportAttendanceToExcel(context);
                  },
                  child: const Text('Export'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: allStudentsWithAttendance.length,
                    itemBuilder: (context, index) {
                      final student = allStudentsWithAttendance[index];
                      final studentName = student['name'];
                      final scNumber = student['sc_number'];
                      final isPresent = student['isPresent'];

                      return ListTile(
                        title: Text('Student: $studentName ($scNumber)'),
                        subtitle: Text(isPresent ? 'Present' : 'Absent'),
                        trailing: Icon(
                          isPresent ? Icons.check_circle : Icons.cancel,
                          color: isPresent ? Colors.green : Colors.red,
                        ),
                      );
                    },
                  ),
                ),
              ],
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
