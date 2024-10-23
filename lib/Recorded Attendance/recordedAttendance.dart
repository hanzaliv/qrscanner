import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'Lecture.dart';
import '../.env';
import '../session_manager.dart';
import 'detailedAttendance.dart';

class RecordedAttendance extends StatefulWidget {
  const RecordedAttendance({super.key});

  @override
  State<RecordedAttendance> createState() => _RecordedAttendanceState();
}

class _RecordedAttendanceState extends State<RecordedAttendance> {

  final List<String> buttons = [' All ', '1 Month', '7 Days', '2 Days', '24 Hours'];
  String selectedButton = ' All ';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  List<Map<String, String>> lectures = [];

  @override
  void initState() {
    super.initState();
    _loadLectures();
  }
  // Load lectures asynchronously and update the state
  Future<void> _loadLectures() async {
    List<Map<String, String>> fetchedLectures = await getFormattedLectures();
    setState(() {
      lectures = fetchedLectures;
    });
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
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  Future<List<Lecture>> fetchLectures() async {
    try {
      final sessionManager = SessionManager(); // Retrieve the singleton instance

      final response = await http.get(
        Uri.parse('$SERVER/get-lectures'), // Adjust URL if needed
        headers: {
          'Accept': 'application/json',
          'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);

        // Map the response to a List<Lecture>
        List<Lecture> lectures = jsonResponse.map<Lecture>((lectureData) {
          return Lecture(
            id: lectureData['id'].toString(),
            courseId: lectureData['course_id'].toString(),
            lectureUserId: lectureData['lecture_user_id'].toString(),
            date: lectureData['date'],
            from: lectureData['from'],
            to: lectureData['to'],
            studentGroupId: lectureData['student_group_id'].toString(),
          );
        }).toList();

        return lectures;
      } else {
        throw Exception('Failed to load lectures');
      }
    } catch (error) {
      throw Exception('Error fetching lectures: $error');
    }
  }

  Future<List<Map<String, String>>> getFormattedLectures() async {
    List<Lecture> lectures = await fetchLectures();

    List<Map<String, String>> formattedLectures = lectures.map((lecture) {
      return {
        "courseUnit": lecture.courseId,
        "lecturer": lecture.lectureUserId,
        "date": lecture.date,
        "time": "${lecture.from} - ${lecture.to}",
        "id": lecture.id,
      };
    }).toList();

    return formattedLectures;
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
          Padding(
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Scroll horizontally if buttons exceed width
                  child: Row(
                    children: buttons.map((button) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedButton == button
                                ? const Color(0xFF88C98A) // Selected button color
                                : Colors.white, // Default button color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            fixedSize: Size(button.length * 17.0, 30), // Adjust width based on word length and set height to 30
                          ),
                          onPressed: () {
                            setState(() {
                              selectedButton = button; // Update selected button
                            });
                          },
                          child: Text(
                            button,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1FCE2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: SizedBox(
                            width: 40,
                            child: Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded( // Wrapping TextField with Expanded to take remaining space
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search', // Placeholder text
                              hintStyle: TextStyle(color: Colors.grey), // Optional: style for placeholder
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 2,
                        color: Colors.black
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Filter By',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          color: Colors.black, // Set text color
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 2,
                        color: Colors.black
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Date:",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Time:",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _selectTime(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE1FCE2),
                          ),
                          child: Text(
                            selectedTime != null
                                ? "${selectedTime!.hourOfPeriod == 0 ? 12 : selectedTime!.hourOfPeriod}:${selectedTime!.minute.toString().padLeft(2, '0')} ${selectedTime!.period == DayPeriod.am ? 'AM' : 'PM'}"
                                : 'Select Time', // Display selected time or default text
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),

                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle action when the button is pressed
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF88C98A),
                        // primary: const Color(0xFF88C98A),
                        minimumSize: const Size(100, 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Find',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.4,
            maxChildSize: 1.0, // Allow the sheet to be dragged to the top of the screen
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFC7FFC9),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                  child: Column(
                    children: [
                      // Table header
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Course \n Unit",
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Lecturer \n ID",
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Date",
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Time",
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "View",
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Make the ListView scrollable inside DraggableScrollableSheet
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController, // Pass the scrollController to ListView
                          itemCount: lectures.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Course Unit column
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      lectures[index]['courseUnit'] ?? '',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  // Lecturer column with wrapping
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 1.0),
                                      child: Text(
                                        lectures[index]['lecturer'] ?? '',
                                        textAlign: TextAlign.center,
                                        maxLines: 2, // Limit the text to a maximum of 2 lines
                                        overflow: TextOverflow.ellipsis, // Display ellipsis if the text exceeds 2 lines
                                      ),
                                    ),
                                  ),
                                  // Date column with wrapping
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      lectures[index]['date'] ?? '',
                                      textAlign: TextAlign.center,
                                      softWrap: true, // Allow wrapping to multiple lines
                                    ),
                                  ),
                                  // Time column
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      lectures[index]['time'] ?? '',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  // Action button
                                  Expanded(
                                    flex: 2,
                                    child: IconButton(
                                        onPressed: (){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DetailedAttendancePage(lecId: lectures[index]['id']!),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.download_for_offline),
                                    )
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
