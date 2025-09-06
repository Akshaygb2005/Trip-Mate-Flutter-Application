import 'dart:ui';
import 'package:fare_calculator/trip.dart';
import 'package:fare_calculator/trip_details.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'side_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  double _opacity = 0.0;
  late AnimationController controller;
  late Animation<Offset> _slideAnimation;
  bool isMenuOpen = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  // for side Menu
  void toggleMenu(bool open) {
    setState(() {
      isMenuOpen = open;
      isMenuOpen ? controller.forward() : controller.reverse();
    });
  }

  //for displaying data
  Stream<QuerySnapshot> getTripStream() {
    try {
      return FirebaseFirestore.instance
          .collection('trips_master')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      print('Error : $e');
      rethrow; // optional
    }
  }

  // for accesing date
  String formatCreatedAt(Timestamp? timestamp) {
    try {
      if (timestamp == null) return 'Date not available';
      DateTime dateTime = timestamp.toDate();
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Future<void> deleteTripCollection(String tripName) async {
    try {
      final collection = FirebaseFirestore.instance.collection(tripName);
      final snapshot = await collection.get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Remove trip from master list
      await FirebaseFirestore.instance
          .collection('trips_master')
          .doc(tripName)
          .delete();
    } catch (e) {
      print("Error deleting trip: $e");
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth * 0.7;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (details.delta.dx > 6 && !isMenuOpen) {
              toggleMenu(true); // swipe right to open
            } else if (details.delta.dx < -6 && isMenuOpen) {
              toggleMenu(false); // swipe left to close
            }
          },
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(seconds: 1),
            child: Stack(
              children: [
                // Main content
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomRight,
                      colors: [Color(0xfff4b6a3), Color(0xfffcb4fc)],
                    ),
                  ),
                  child: Column(
                    children: [

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

                      const SizedBox(height: 10),
                      /* Main content */
                      Expanded(
                        child: StreamBuilder(
                            stream: getTripStream(),
                            builder: (context,Snapshots){
                              if (Snapshots.hasError) {
                                return Center(child: Text('Error: ${Snapshots.error}'));
                              }
                              if (Snapshots.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }
                              if (!Snapshots.hasData || Snapshots.data!.docs.isEmpty) {
                                return Center(child: Text('No trips found.'));
                              }

                              final tripDocs = Snapshots.data!.docs;
                              return ListView.builder(
                                  itemCount: tripDocs.length,
                                  itemBuilder: (context,index){
                                    final tripName = tripDocs[index];
                                    final data = tripName.data() as Map<String, dynamic>;

                                    // Safely read the createdAt timestamp
                                    final Timestamp? createdAt = data['createdAt'] as Timestamp?;;


                                    return Padding(
                                      padding: const EdgeInsets.all(7.0),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(25),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                              child: Center(
                                                child: Container(
                                                  height: 80,
                                                  width: MediaQuery.of(context).size.width * 0.96,
                                                  padding: EdgeInsets.all(9),
                                                  decoration: BoxDecoration(
                                                    color: Color.fromRGBO(255, 255, 255, 0.35),
                                                    borderRadius: BorderRadius.circular(25),
                                                    border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.3)),
                                                  ),

                                                  // to get pop up context menu
                                                  child: FocusedMenuHolder(
                                                    menuWidth: screenWidth*0.3,
                                                    menuItemExtent: 45,
                                                    blurSize: 1,
                                                    menuBoxDecoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    animateMenuItems: true,
                                                    duration: Duration(milliseconds: 200),
                                                    openWithTap: false,
                                                    blurBackgroundColor : Colors.grey.shade900,
                                                    onPressed: (){},
                                                    menuItems: <FocusedMenuItem>[

                                                      //edit button
                                                      FocusedMenuItem(
                                                          title: Text('Edit',style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors.black),
                                                          ),
                                                          //backgroundColor :
                                                          trailingIcon: Icon(Icons.edit,color: Colors.black),
                                                          onPressed: (){}
                                                      ),

                                                      //delete button
                                                      FocusedMenuItem(
                                                          title: Text('delete',style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors.black),
                                                          ),
                                                          backgroundColor : Colors.red,
                                                          trailingIcon: Icon(Icons.delete,color: Colors.black),
                                                          onPressed: ()async {
                                                            final confirm = await showDialog(
                                                              context: context,
                                                              builder: (context) => AlertDialog(
                                                                title: Text('Delete Trip ${tripName.id}', style: TextStyle(fontSize: 16)),
                                                                content: Text(
                                                                  'Are you sure you want to delete this trip?',
                                                                  style: TextStyle(fontSize: 14),
                                                                ),
                                                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                                actionsPadding: EdgeInsets.only(right: 10, bottom: 5),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () => Navigator.pop(context, false),
                                                                    child: Text('Cancel', style: TextStyle(fontSize: 13)),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed: () => Navigator.pop(context, true),
                                                                    child: Text('Delete', style: TextStyle(fontSize: 13)),
                                                                  ),
                                                                ],
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(12),
                                                                ),
                                                              ),
                                                            );

                                                            if (confirm == true) {
                                                              await deleteTripCollection(tripName.id);
                                                              setState(() {});
                                                            }
                                                          }
                                                      ),
                                                    ],
                                                    child: ListTile(
                                                      title: Text(tripName.id,style: TextStyle(
                                                          color :Colors.black,
                                                          fontWeight: FontWeight.w500,
                                                          fontSize : 22
                                                       ),
                                                      ),
                                                      subtitle: Text("Created on: ${formatCreatedAt(createdAt)}"),
                                                      onTap : (){
                                                        Get.to(()=>Details(Trip_name: tripName.id));
                                                      },
                                                    ),
                                                  )
                                                                                          ),
                                              ),
                                          )
                                          )
                                        ],
                                      ),
                                    );

                                  });
                            }
                        )
                      )
                    ],
                  ),
                ),

                /* Add Trip button */
                Align(
                  alignment: Alignment.bottomCenter,

                  /* Stack to give blur effect to button*/
                  child: InkWell(
                    onTap: (){
                      Get.to(()=>Trip());
                    },
                    child: Stack(
                      children: [
                        Padding(
                          padding:  EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02),
                          child: Container(
                            width: screenWidth*0.75,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.42),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Center(
                              child: Text('Add Trip',style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20
                              ),),
                            ),
                          ),
                        ),
                    
                      ],
                    ),
                  ),
                ),

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
                SideBar(
                  slideAnimation: _slideAnimation,
                  controller: controller,
                  onClose: () => toggleMenu(false),
                  HomeButton: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


