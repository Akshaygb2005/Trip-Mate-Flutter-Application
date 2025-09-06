import 'dart:ui';
import 'package:flutter/material.dart';
import 'side_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Fare extends StatefulWidget {
  final String trip_name;
  Fare({required this.trip_name });

  @override
  State<Fare> createState() => _detailsState();
}

class _detailsState extends State<Fare> with SingleTickerProviderStateMixin {
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

    calculate();
  }

  // for side Menu
  void toggleMenu(bool open) {
    setState(() {
      isMenuOpen = open;
      isMenuOpen ? controller.forward() : controller.reverse();
    });
  }

  List<String> results = [];
  double sum = 0;
  void calculate() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection(widget.trip_name).get();

    // 🔹 Extract documents into a list of maps using a loop
    List<Map<String, dynamic>> members = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      members.add(data);
    }

    // 🔹 Calculate total & average

    for (var m in members) {
      sum += m['Amount paid'];
    }
    double avg = sum / members.length;

    // 🔹 Prepare balances (positive = should receive, negative = should pay)
    List<Map<String, dynamic>> balances = [];
    for (var m in members) {
      balances.add({
        'Name': m['Name'],
        'Balance': m['Amount paid'] - avg,
      });
    }

    // 🔹 Separate payers & receivers
    List<Map<String, dynamic>> payers =
    balances.where((b) => b['Balance'] < 0).toList();
    List<Map<String, dynamic>> receivers =
    balances.where((b) => b['Balance'] > 0).toList();

    // 🔹 Do settlements
    List<String> tempResults = [];
    for (var payer in payers) {
      double payAmount = -payer['Balance']; // make positive
      String payerName = payer['Name'];

      for (var receiver in receivers) {
        if (payAmount == 0) break;

        double receiveAmount = receiver['Balance'];
        String receiverName = receiver['Name'];

        double settled = payAmount < receiveAmount ? payAmount : receiveAmount;

        if (settled > 0) {
          tempResults.add(
              "$payerName pays Rs ${settled.toStringAsFixed(2)} to $receiverName");

          payer['Balance'] += settled;
          receiver['Balance'] -= settled;
          payAmount -= settled;
        }
      }
    }

    // 🔹 Update UI
    setState(() {
      results = tempResults;
    });
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

                              Text(widget.trip_name,style : TextStyle(
                                  color : Colors.black,
                                  fontSize : 25,
                                  fontWeight: FontWeight.w500
                              )),

                      Padding(
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

                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Text('Total Spent', style : TextStyle(
                                              color: Colors.black,
                                              fontSize: 22,
                                            )),

                                            Text(sum.toStringAsFixed(2),style : TextStyle(
                                              color : Colors.black,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w500
                                            ))
                                          ],
                                        )
                                    ),
                                  ),
                                )
                            )
                          ],
                        ),
                      )
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
                                child : ListView.builder(
                                    itemCount: results.length,
                                    itemBuilder: (context, index){
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

                                                        child: ListTile(
                                                          title: Padding(
                                                            padding: const EdgeInsets.all(2.0),
                                                            child: Text(results[index],style: TextStyle(
                                                                color :Colors.black,
                                                                fontWeight: FontWeight.w500,
                                                                fontSize : 20
                                                            ),
                                                            ),
                                                          ),
                                                          onTap : (){},
                                                        )
                                                    ),
                                                  ),
                                                )
                                            )
                                          ],
                                        ),
                                      );
                                    }
                                )
                            )
                        ),

                        SizedBox(height: screenHeight * 0.3,),

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

