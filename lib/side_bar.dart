import 'dart:ui';
import 'package:fare_calculator/home_page.dart';
import 'package:fare_calculator/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SideBar extends StatelessWidget {
  final Animation<Offset> slideAnimation;
  final AnimationController controller;
  final VoidCallback onClose;
  final bool HomeButton;

  const SideBar({
    Key? key,
    required this.slideAnimation,
    required this.controller,
    required this.onClose,
    required this.HomeButton
  }) : super(key: key);

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth * 0.7;

    return SlideTransition(
      position: slideAnimation,
      child: SafeArea(
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: Container(
            width: sidebarWidth,
            height: double.infinity,
            child: Stack(
              children: [
                // Glass effect background
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 0.2),
                    ),
                  ),
                ),
                // Sidebar content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Icon(Icons.close, color: Colors.white,),
                      title: Text(
                        "Close",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: onClose,
                    ),
                    Divider(color: Colors.black, thickness: 0.7, indent: 0, endIndent: 0),
                    ListTile(
                      leading: Icon(Icons.account_circle, color: Colors.white),
                      title: Text(
                        "Profile",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () => print("Profile tapped"),
                    ),
                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.white),
                      title: Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: ()async {
                        await signOut();
                        onClose(); // close side Bar
                        Get.to(()=>LoginPage());
                      },
                    ),
                    HomeButton?
                    ListTile(
                      leading: Icon(Icons.home, color: Colors.white),
                      title: Text(
                        "Home",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () => Get.to(()=>HomePage()),
                    ) : SizedBox()
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
