import 'dart:ui';
import 'package:fare_calculator/trip.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'side_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'calculate.dart';

class Details extends StatefulWidget {
  final String Trip_name;
  Details({required this.Trip_name });

  @override
  State<Details> createState() => _detailsState();
}

class _detailsState extends State<Details> with SingleTickerProviderStateMixin {
  TextEditingController name = TextEditingController();
  TextEditingController amount = TextEditingController();
  bool error = false;
  String msg ='';
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

  // to add participant
  add_participant() async{
    final String PName = name.text.trim();
    final num? amount_paid = num.tryParse(amount.text);
    final time = DateTime.now();
    final String date = '${time.day}-${time.month}-${time.year}';

    if (PName.isNotEmpty && amount_paid!=null){
    try {
        await FirebaseFirestore.instance.collection(widget.Trip_name)
            .doc(PName)
            .set({
          'Name': PName,
          'Amount paid': amount_paid,
          'Date' : date,
          'createdAt': FieldValue.serverTimestamp(),
        });
        setState(() {
          error = false;
          msg = 'Mate added successfully';
        });

        name.clear();
        amount.clear();
    } catch (e){
      setState(() {
        error = true;
        msg = 'Error: ${e.toString()}';
      });
    }
   } else{
      setState(() {
        error = true;
        msg = 'Please fill all the fields!';
      });
    }
  }

  Stream<QuerySnapshot> getTripStream() {
    try {
      return FirebaseFirestore.instance
          .collection(widget.Trip_name)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      print('Error : $e');
      rethrow; // optional
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
                return ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Stack(
                      children: [
                        // Top image
                        Align(
                          alignment: Alignment.topCenter,
                          child: Column(
                            children: [
                              Container(
                                width: screenWidth,
                                height: screenHeight * 0.25,
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

                              SizedBox(height: 20,),

                              Text(widget.Trip_name,style : TextStyle(
                                color : Colors.black,
                                fontSize : 25,
                                fontWeight: FontWeight.w500
                              ))
                            ],
                          ),
                        ),

                        Positioned(
                          left : 0,
                          right : 0,
                          top : (screenHeight * 0.25) + 60,
                          child : Container(
                            height : screenHeight * 0.45,
                            color : Colors.transparent,
                            child : StreamBuilder(
                                stream: getTripStream(), builder: (context,Snapshots){
                              if (Snapshots.hasError) {
                                return Center(child: Text('Error: ${Snapshots.error}'));
                              }
                              if (Snapshots.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }
                              if (!Snapshots.hasData || Snapshots.data!.docs.isEmpty) {
                                return Center(child: Text('No trips found.'));
                              }

                              final docs = Snapshots.data!.docs;
                              return ListView.builder(
                                  itemCount: docs.length,
                                  itemBuilder: (context, index){
                                    final data = docs[index].data() as Map<String, dynamic>;
                                    final Name = data['Name'] ?? '';
                                    final amountpaid = data['Amount paid'];

                                    return Padding(
                                      padding: const EdgeInsets.all(7.0),
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
                                                          title: Text('Delete Mate ${Name}', style: TextStyle(fontSize: 16)),
                                                          content: Text(
                                                            'Are you sure you want to delete Mate?',
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
                                                        await FirebaseFirestore.instance.collection(widget.Trip_name).doc(Name).delete();
                                                        setState(() {});
                                                      }
                                                    }
                                                ),
                                              ],
                                              child: ListTile(
                                                title: Text(Name,style: TextStyle(
                                                    color :Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize : 22
                                                ),
                                                ),
                                                subtitle: Text(" Paid : ₹${amountpaid}"),
                                                onTap : (){},
                                              ),
                                            )
                                        ),
                                      ),
                                    );
                                  }
                                  );
                            })
                          )
                        ),

                        SizedBox(height: screenHeight * 0.3,),
                        // Input Fields
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const SizedBox(height: 80), // Space for image

                                inputField('Enter mate name', name, screenWidth, false),

                                const SizedBox(height: 18),

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
                                ),

                                const SizedBox(height: 10),

                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Fare(trip_name: widget.Trip_name)));
                                      },
                                    child: Center(
                                      child: Container(
                                        width: screenWidth*0.55,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(25)
                                        ),
                                        child : Center(
                                          child: Text('Calculate',style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20
                                          )),
                                        )
                                      ),
                                    ))
                              ],
                            ),
                          ),
                        ),

                        // Add Trip button pinned to bottom
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FloatingActionButton(
                              onPressed:  add_participant,
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.add_rounded,color: Colors.white,size: 20,),
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
                );
              },
            ),
          ),
        ),
      ),
    );
}
}

Widget inputField(String hint, TextEditingController controller, double width,bool keyboard) {
  return Container(
    width: width * 0.75,
    height: 50,
    child: TextField(
      controller: controller,
      textInputAction: TextInputAction.next,
      keyboardType: keyboard ? TextInputType.number : TextInputType.text,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: 20,
      ),
      decoration: InputDecoration(
        hintText: '  $hint',
        filled: true,
        fillColor: const Color.fromRGBO(255, 255, 255, 0.42),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}
