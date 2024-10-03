import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
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
            print('Barcode found ${barcode.rawValue}');
          }

          if (image != null){
            showDialog(context: context, builder: (context){
                return AlertDialog(
                  title: Text(
                    barcodes.first.rawValue ?? "",
                  ),
                  content: Image(
                      image: MemoryImage(image)
                  ),
                );
            });
          }
        },
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
      //
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // bottomNavigationBar: const BottomAppBar(
      //   color: Colors.white,
      //   shape: CircularNotchedRectangle(),
      //   notchMargin: 15.0,
      //   height: 100,
      // ),
    );

  }
}
