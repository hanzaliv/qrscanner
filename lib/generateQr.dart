import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';


class GenerateQR extends StatefulWidget {
  const GenerateQR({super.key});

  @override
  State<GenerateQR> createState() => _GenerateQRState();
}

class _GenerateQRState extends State<GenerateQR> {

  String? name;
  String? id;

  bool _isValidID = true;



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
      )
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
                            decoration: const InputDecoration(
                              hintText: 'P.R. Perera', // Placeholder text
                              hintStyle: TextStyle(color: Colors.grey), // Optional: style for placeholder
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (value){
                              setState(() {
                                name = value;
                              });
                            },

                          ),
                        ),
                        const SizedBox(height: 20),
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
                              hintStyle: TextStyle(color: Colors.grey), // Optional: style for placeholder
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
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
              height: MediaQuery.of(context).size.height * 0.35,
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
                        onPressed: () {

                          if(id != null){
                            showDialog(context: context, builder: (context){
                              return AlertDialog(
                                title: const Text(
                                  "QR",
                                ),
                                content: PrettyQrView.data(data: id!)

                              );
                            });
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
                          // Handle the 'Show' button press
                        },
                        child: const Text(
                            'Show',
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
