import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'Lecture.dart';
import '../.env';
import '../session_manager.dart';

class DetailedAttendancePage extends StatefulWidget {
  final String lecId;

  const DetailedAttendancePage({super.key, required this.lecId});

  @override
  State<DetailedAttendancePage> createState() => _DetailedAttendancePageState();
}

class _DetailedAttendancePageState extends State<DetailedAttendancePage> {

  List<dynamic> attendanceDetails = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    getLectureAttendance(int.parse(widget.lecId));
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
          attendanceDetails = responseData['attendanceDetails'];
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
    } finally {
      setState(() {
        isLoading = false;
      });
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
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFC7FFC9),
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : attendanceDetails.isEmpty
          ? Center(child: Text("No attendance data available"))
          : ListView.builder(
        itemCount: attendanceDetails.length,
        itemBuilder: (context, index) {
          final attendance = attendanceDetails[index];
          final studentName = attendance['student_name'];
          final scNumber = attendance['sc_number'];
          final attendTime = attendance['attend_time'] ?? 'N/A';
          final studentGroupId = attendance['student_group_id'];

          return ListTile(
            title: Text('Student: $studentName ($scNumber)'),
            subtitle: Text('Group ID: $studentGroupId | Attend Time: $attendTime'),
            trailing: Icon(Icons.check_circle, color: Colors.green)
          );
        },
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
