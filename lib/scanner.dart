import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:convert';  // For decoding JSON
import 'package:http/http.dart' as http;

import 'session_manager.dart';
import '.env';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {

  final String lectureId;

  const ScannerPage({
    super.key,
    required this.lectureId,
  });

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {

  String? barcode;
  String? scNumber;
  String? name;
  bool? isValidBarcode;

  Map<String, String> splitBarcode(String barcode) {
    // Split the barcode by '~'
    List<String> parts = barcode.split('~');

    // Return a map containing the ID and name
    return {
      'id': parts[0],
      'name': parts[1],
    };
  }

  Future<void> _markStudentAttendance() async {
    try {
      final sessionManager = SessionManager(); // Retrieve the singleton instance
      print('lectureId: ${widget.lectureId}');
      print('scNumber: $scNumber');
      // Prepare the request body
      var body = jsonEncode({
        'lec_id': widget.lectureId,
        'sc_number': scNumber,
      });

      final response = await http.post(
        Uri.parse('$SERVER/mark-attendance'),
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

        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance marked for $name')),
        );
      } else {
        name = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No Matching Student Found')),
        );
        print('No matching student found');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking student: $error')),
      );
      print('Error marking student: $error');
    }
  }

  void _handleAttendance(BuildContext context) async {
    // Show loading dialog
    _showLoadingDialog(context);

    // Run the async operation
    await _markStudentAttendance();

    // Close the loading dialog
    if (context.mounted) {
      Navigator.pop(context);
    }
    resetScanner();
    Navigator.pop(context);

  }

  void splitBarcodeAndValidate(String barcode, BuildContext context) {
    // Check if the barcode contains the '~' symbol and has two parts
    if (barcode.contains('~')) {
      List<String> parts = barcode.split('~');

      // Ensure both ID and Name exist after splitting
      if (parts.length == 2) {
        String id = parts[0];
        String name = parts[1];
        isValidBarcode = true;

        // Valid barcode, proceed with ID and Name
        print('ID: $id');
        print('Name: $name');
      } else {
        // Show an invalid barcode alert if parts are missing
        showAlert(context, 'Invalid Barcode', 'The barcode format is incorrect.');
        isValidBarcode = false;

      }
    } else {
      // Show an alert if the barcode doesn't contain the correct format
      showAlert(context, 'Invalid Barcode', 'The barcode format is incorrect.');
      isValidBarcode = false;

    }
  }

  void showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Please wait..."),
            ],
          ),
        );
      },
    );
  }

  void resetScanner() {
    // Reset the state so the scanner can process another barcode
    setState(() {
      barcode = null;
      scNumber = null;
      name = null;
      isValidBarcode = null;
    });
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
      // resizeToAvoidBottomInset: false,
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          returnImage: true,
        ),
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          final Uint8List? image = capture.image;


          for(final barcode in barcodes) {
            splitBarcodeAndValidate(barcode.rawValue!, context);
            if(isValidBarcode!){
              print('Barcode found ${barcode.rawValue}');
              Map<String, String> result = splitBarcode(barcode.rawValue!);
              scNumber = result['id'];
              name = result['name'];
            }else{
              print('Barcode not found');
            }

          }

          if (image != null && isValidBarcode!){
            showDialog(context: context, builder: (context){
                return AlertDialog(
                  title: Text(
                    "Barcode Found!",
                  ),
                  content: Column(
                    children: [
                      Image(
                          image: MemoryImage(image)
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

                          onPressed: (){
                            _handleAttendance(context);
                          },
                          child: const Text(
                              'Submit',
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
                );
            });
          }
        },
      ),
    );

  }
}
