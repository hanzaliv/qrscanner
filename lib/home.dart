import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Mark Attendance/markAttendance.dart';
import 'generateQr.dart';
import 'Recorded Attendance/recordedAttendance.dart';
import 'Data Entry/course.dart';
import 'Data Entry/lecturer.dart';
import 'Data Entry/assistance.dart';
import 'Data Entry/student.dart';
import 'Data Entry/group.dart';
import 'menu.dart';



class Home extends StatefulWidget {
  final String userRole;
  final String userId;

  const Home({super.key, required this.userRole, required this.userId});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestStoragePermission();
  }

  Future<void> _requestStoragePermission() async {
    var status = await Permission.manageExternalStorage.request();
    // var status = await Permission.storage.request();
    if (!status.isGranted) {
      // Handle the case when the permission is not granted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission is required to proceed')),
      );
    }
  }

  void _showPopupMenuLecturer(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Select an Option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.book),
                title: const Text('Course'),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.push(context, (MaterialPageRoute(builder: (context) => const Course())));
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Lecturer'),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.push(context, (MaterialPageRoute(builder: (context) => const Lecturer())));
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Lab Assistant'),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.push(context, (MaterialPageRoute(builder: (context) => const Assistance())));
                },
              ),
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text('Student'),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.push(context, (MaterialPageRoute(builder: (context) => const Student())));
                },
              ),
              ListTile(
                leading: const Icon(Icons.grade),
                title: const Text('Student Group'),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.push(context, (MaterialPageRoute(builder: (context) => const Group())));

                },
              ),

            ],
          ),
        );
      },
    );
  }

  void _showPopupMenuAssistant(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Select an Option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text('Student'),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.push(context, (MaterialPageRoute(builder: (context) => const Student())));
                },
              ),
              ListTile(
                leading: const Icon(Icons.grade),
                title: const Text('Student Group'),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.push(context, (MaterialPageRoute(builder: (context) => const Group())));

                },
              ),

            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
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

      drawer:const Menu()
      ,
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4, // Bottom 50% of the screen
              decoration: const BoxDecoration(
                color: Color(0xFFC7FFC9), // Background color #C7FFC9
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), // Customize the shape as desired
                  topRight: Radius.circular(30),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              Image.asset(
                'assets/images/home.cover.png',
                width: 320,
              ),
              const SizedBox(height: 40),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF9AE82D),
                          offset: Offset(4, 4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                        onTap: () {
                          Navigator.push(context, (MaterialPageRoute(builder: (context) => const GenerateQR())));

                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/images/buttons/qr.logo.png',
                                  width: 100,
                                ),
                                const Text(
                                  'Generate the QR Code',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  Container(
                    width: 130,
                    height: 130,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFDFEF2B),
                          offset: Offset(4, 4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        onTap: widget.userRole.toLowerCase() == 'student' ? null : () {
                          Navigator.push(context, (MaterialPageRoute(builder: (context) => const MarkAttendance())));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Stack(
                            children: [
                              Image.asset(
                                'assets/images/buttons/mark.attendance.png',
                                width: 100,
                              ),
                              const Center(
                                child: Text(
                                  'Mark The Attendance',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: Colors.black,
                                
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF9AE82D),
                          offset: Offset(4, 4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        onTap: widget.userRole.toLowerCase() == 'student' ? null : () {
                          Navigator.push(context, (MaterialPageRoute(builder: (context) => const RecordedAttendance())));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Stack(
                            children: [
                              Image.asset(
                                'assets/images/buttons/attendance.png',
                                width: 100,
                              ),
                              const Center(
                                child: Text(
                                  'Recorded Attendance',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  Container(
                    width: 130,
                    height: 130,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFDFEF2B),
                          offset: Offset(4, 4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                        onTap: widget.userRole.toLowerCase() == 'student' ? null : (){
                          widget.userRole.toLowerCase() == 'lecturer' ? _showPopupMenuLecturer(context) : _showPopupMenuAssistant(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Stack(
                            children: [
                              Image.asset(
                                'assets/images/buttons/data.entry.png',
                                width: 100,
                              ),
                              const Center(
                                child: Text(
                                  'Data Entry',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100.0,
            height: 100.0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFC7FFC9),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          SizedBox(
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
                // Handle action when the floating button is pressed
                //Navigator.of(context).pop();
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
        ],
      ),
      // floatingActionButton: SizedBox(
      //   width: 75.0,
      //   height: 75.0,
      //   child: FloatingActionButton(
      //     backgroundColor: Colors.white,
      //     shape: const CircleBorder(
      //       side: BorderSide(
      //         color: Colors.white,
      //         width: 2.0,
      //       ),
      //     ),
      //     onPressed: () {
      //       Navigator.of(context).pop();
      //     },
      //     child: Padding(
      //       padding: const EdgeInsets.all(10.0),
      //       child: Image.asset(
      //         'assets/images/logo.png',
      //         fit: BoxFit.cover,
      //       ),
      //     ),
      //   ),
      // ),
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
