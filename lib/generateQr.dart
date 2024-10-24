import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'dart:convert';  // For decoding JSON
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'session_manager.dart';
import 'menu.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/services.dart'; // For ByteData
//import 'dart:ui' as ui;
// import 'package:path/path.dart' as path;


import '.env';


class GenerateQR extends StatefulWidget {
  const GenerateQR({super.key});

  @override
  State<GenerateQR> createState() => _GenerateQRState();
}

class _GenerateQRState extends State<GenerateQR> {
  TextEditingController _nameController = TextEditingController();

  String? name;
  String? id;
  String? qrData;
  String? qrImageName;

  bool _isValidID = true;

  @override
  void initState() {
    super.initState();

    // Initialize the controller with the name if it's not null
    if (name != null) {
      _nameController.text = name!;
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

  Future<void> _findStudentByScNumber() async {
    try {
      final sessionManager = SessionManager(); // Retrieve the singleton instance

      // Prepare the request body
      var body = jsonEncode({'sc_number': id!});

      final response = await http.post(
        Uri.parse('$SERVER/get-name-by-scnumber'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json', // Indicate that the body is JSON
          'Cookie': '${sessionManager.sessionCookie}; ${sessionManager.csrfCookie}',
        },
        body: body, // Send the sc_number in the request body
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        showTopSnackBar(context, 'Matching Student Found!', Colors.green);

        setState(() {
          // Extract 'name' from the response
          name = jsonResponse['name'];
          _nameController.text = jsonResponse['name'];
          qrData = '${id!}~${name!}';
          // var newId = id?.replaceAll('/', '_') ?? '';
          // qrImageName =  newId + '_' + name!;
          qrImageName = name!;
        });
      } else if (response.statusCode == 400){
        name = null;
        showTopSnackBar(context, 'No Matching Student Found!', Colors.red);
      } else {
        showTopSnackBar(context, 'Error fetching student: ${response.statusCode}', Colors.red);
      }
    } catch (error) {

      showTopSnackBar(context, 'Error fetching student: $error' , Colors.red);

    }
  }

  Future<Uint8List?> generateQRCode(String data) async {
    try {
      final qrCode = QrCode.fromData(
        data: data,
        errorCorrectLevel: QrErrorCorrectLevel.H,
      );

      final qrImage = QrImage(qrCode);
      final ByteData? qrImageByteData = await qrImage.toImageAsBytes(
        size: 512,
        format: ImageByteFormat.png,
        decoration: const PrettyQrDecoration(
          background: Colors.white,
          image: PrettyQrDecorationImage(
            image: AssetImage('assets/images/logo.png'),

          )
        ),
      );
      // final ByteData? qrImageByteData = await qrImage.toImageData(512, format: ImageByteFormat.png);

      if (qrImageByteData != null) {
        return qrImageByteData.buffer.asUint8List();
      }
      return null;
    } catch (e) {
      // print("Error generating QR Code: $e");
      return null;
    }
  }

  void _showQrDialog(BuildContext context, Uint8List qrImageBytes, String imageName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("QR Code"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200, // Define width
                height: 200, // Define height
                child: Image.memory(qrImageBytes),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await Permission.storage.request();
                  await _saveQrImage(qrImageBytes, imageName, context);
                },
                child: const Text('Save to Gallery'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveQrImage(Uint8List imageBytes, String imageName, BuildContext context) async {
    try {
      // Request storage permissions for Android 10+ or manageExternalStorage for Android 11+
      var status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission not granted');
      }

      // Define the directory and file paths for the Downloads folder
      const String downloadsDir = '/storage/emulated/0/Download/';
      final String filePath = '$downloadsDir/$imageName QR.png';

      // Save the image file in the Downloads folder
      final File file = File(filePath);
      await file.writeAsBytes(imageBytes);

      // Confirm the image was saved
      showTopSnackBar(context, 'Image Saved To Downloads', Colors.green);
    } catch (error) {
      showTopSnackBar(context, 'Error saving image: $error', Colors.red);
    }
  }
  void showQRCodeDialog(BuildContext context, Uint8List qrImageBytes) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("QR Code"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.memory(qrImageBytes),
              const SizedBox(height: 20),
              // ElevatedButton(
              //   // onPressed: _saveQrImage,
              //   child: const Text("Save to Gallery"),
              // ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent resizing when the keyboard appears
      appBar: AppBar(
        title: const Text(
          'Generate QR Code',
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
      drawer: const Menu()
      ,
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      'Enter Student Details',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                            "Student ID:",
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                            )
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: 305,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1FCE2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'SC/20xx/xxxxx', // Placeholder text
                              hintStyle: const TextStyle(color: Colors.grey), // Optional: style for placeholder
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                              border: InputBorder.none,
                              errorText: _isValidID ? null : 'Invalid ID format', // Show error if the ID is invalid
                            ),
                            onChanged: (value) {
                              setState(() {
                                // Check if the entered value matches the required format
                                _isValidID = RegExp(r'^SC/20\d{2}/\d{5}$').hasMatch(value);
                                if (_isValidID) {
                                  id = value;
                                }
                              });
                            },
                          ),

                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 140,
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF88C98A), // Button background color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15), // Border radius of 15
                              ),
                            ),
                            onPressed: () {
                              if (_isValidID) {
                                _findStudentByScNumber();
                              }else{
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Invalid ID format')),
                                );
                              }
                            },
                            child: const Text(
                                'Find',
                                style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                    color: Colors.black
                                )),
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Text(
                            "Student Name:",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        )
                        ),
                        const SizedBox(height: 5,),
                        Container(
                          width: 305,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1FCE2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            controller: _nameController, // Set the controller to the TextField
                            decoration: const InputDecoration(
                              // hintText: 'P.R. Perera', // Placeholder text
                              hintStyle: TextStyle(color: Colors.grey), // Optional: style for placeholder
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              border: InputBorder.none,
                            ),
                            enabled: false, // Make the TextField uneditable if name is not null
                            readOnly: true,

                          )
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: const BoxDecoration(
                color: Color(0xFFC7FFC9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF88C98A), // Button background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15), // Border radius of 15
                          ),
                        ),
                        onPressed: () async {
                          if (qrData != null) {
                            Uint8List? qrImageBytes = await generateQRCode(qrData!);
                            _showQrDialog(context, qrImageBytes!, qrImageName!);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No QR data to generate')),
                            );
                          }
                        },

                        child: const Text(
                            'Generate',
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                                color: Colors.black
                            )),
                      ),
                    ),
                    // Show Button
                    // SizedBox(
                    //   width: 140,
                    //   height: 40,
                    //   child: ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: const Color(0xFF88C98A), // Button background color
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(15), // Border radius of 15
                    //       ),
                    //     ),
                    //     onPressed: () {
                    //       // Handle the 'Show' button press
                    //     },
                    //     child: const Text(
                    //         'Show',
                    //         style: TextStyle(
                    //           fontFamily: 'Roboto',
                    //           fontWeight: FontWeight.w500,
                    //           fontSize: 17,
                    //           color: Colors.black
                    //         )),
                    //   ),
                    // ),
                  ],
                ),
              )
              ,
            ),
          ),
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
