
import 'package:flutter/material.dart';

import 'package:dropdown_search/dropdown_search.dart';

import 'scanner.dart';

class MarkAttendance extends StatefulWidget {
  const MarkAttendance({super.key});

  @override
  State<MarkAttendance> createState() => _MarkAttendanceState();
}

class _MarkAttendanceState extends State<MarkAttendance> {

  final dropDownKeyCourseUnit = GlobalKey<DropdownSearchState>();
  final dropDownKeyLecturer = GlobalKey<DropdownSearchState>();

  String? selectedCourseUnit;
  String? selectedLecturer;
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

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
                        DropdownSearch<String>(
                          key: dropDownKeyCourseUnit,
                          items: (filter, infiniteScrollProps) =>
                          ["PHY2222", "PHY12222", "PHY1234", "CSC1232","CHE2163"],
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
                          items: (filter, infiniteScrollProps) =>
                          ["Mr. A Perera", "Mr. J Sunil", "Prof. Amarasooriya", "Prof. Silva","Prof. HHH"],
                          onChanged: (value) {
                            setState(() {
                              selectedLecturer = value; // Update selected lecturer
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

                                onPressed: () {
                                  Navigator.push(context, (MaterialPageRoute(builder: (context) => const ScannerPage())));
                                },
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
                        // DropdownMenu(
                        //   enableSearch: true,
                        //   enableFilter: true,
                        //   dropdownMenuEntries: [
                        //     DropdownMenuEntry(value: 1, label: "'phy2222"),
                        //     DropdownMenuEntry(value: 2, label: "phy2223"),
                        //     DropdownMenuEntry(value: 3, label: "phy2224"),
                        //   ],
                        //     onSelected: (value){},
                        // ),

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
