import 'dart:ui';
import 'package:fare_calculator/side_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Trip extends StatefulWidget {
  const Trip({super.key});

  @override
  State<Trip> createState() => _TripState();
}

class _TripState extends State<Trip> with SingleTickerProviderStateMixin {
  TextEditingController trip_name = TextEditingController();
  TextEditingController participant_name = TextEditingController();
  TextEditingController amount = TextEditingController();

  late AnimationController controller;
  late Animation<Offset> _slideAnimation;
  bool isMenuOpen = false;
  bool error = false;
  double _opacity = 0.0;
  String msg = '';

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  void toggleMenu(bool open) {
    setState(() {
      isMenuOpen = open;
      isMenuOpen ? controller.forward() : controller.reverse();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void add_trip() async {
    final String TripName = trip_name.text.trim();
    final String ParticpantName = participant_name.text.trim();
    final num? EnteredAmount = num.tryParse(amount.text.trim());
    final time = DateTime.now();
    final String date = '${time.day}-${time.month}-${time.year}';

    if (TripName.isNotEmpty && ParticpantName.isNotEmpty && EnteredAmount != null) {
      try {
        await FirebaseFirestore.instance
            .collection(TripName)
            .doc(ParticpantName.toLowerCase())
            .set({
          'Name': ParticpantName,
          'Amount paid': EnteredAmount,
          'Date': date,
        });

        await FirebaseFirestore.instance
            .collection('trips_master')
            .doc(TripName)
            .set({'createdAt': DateTime.now()});

        setState(() {
          error = false;
          msg = 'Trip added successfully!';
        });

        trip_name.clear();
        participant_name.clear();
        amount.clear();
      } catch (e) {
        setState(() {
          error = true;
          msg = 'Error: ${e.toString()}';
        });
      }
    } else {
      setState(() {
        error = true;
        msg = 'Please fill all the fields!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(seconds: 1),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomRight,
              colors: [Color(0xfff4b6a3), Color(0xfffcb4fc)],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Stack(
                        children: [
                          // Top image
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: screenWidth,
                              height: MediaQuery.of(context).size.height * 0.25,
                              clipBehavior: Clip.antiAlias,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(40),
                                  bottomLeft: Radius.circular(40),
                                ),
                              ),
                              child: Image.asset(
                                'assets/Images/travel.webp',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.3,),
                          // Input Fields
                          Padding(
                            padding: const EdgeInsets.only(bottom: 100.0),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 180), // Space for image

                                  inputField('Enter Trip name', trip_name, screenWidth, false),

                                  const SizedBox(height: 25),

                                  inputField('Enter mate name', participant_name, screenWidth, false),

                                  const SizedBox(height: 25),

                                  inputField('Enter amount paid ', amount, screenWidth, true),

                                  const SizedBox(height: 2),

                                  error
                                      ? Text(
                                    msg,
                                    style: TextStyle(color: Colors.red),
                                  )
                                      : Text(
                                    msg,
                                    style: TextStyle(color: Colors.green),
                                  )
                                ],
                              ),
                            ),
                          ),

                          // Add Trip button pinned to bottom
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: add_trip,
                                child: Container(
                                  width: screenWidth * 0.75,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(255, 255, 255, 0.42),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Save Trip',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Menu Button
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.menu_rounded,
                                    color: Colors.black, size: 26),
                                onPressed: () => toggleMenu(!isMenuOpen),
                              ),
                            ),
                          ),

                          // Sidebar
                          if (isMenuOpen)
                          SideBar(
                            slideAnimation: _slideAnimation,
                            controller: controller,
                            onClose: () => toggleMenu(false),
                            HomeButton: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Input Field Widget
  Widget inputField(String hint, TextEditingController controller, double width, bool isNumeric) {
    return Container(
      width: width * 0.75,
      height: 50,
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.next,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 20,
        ),
        decoration: InputDecoration(
          hintText: '  $hint',
          filled: true,
          fillColor: const Color.fromRGBO(255, 255, 255, 0.40),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
