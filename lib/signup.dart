import 'package:fare_calculator/working.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class Signup extends StatefulWidget{
  SignupState createState() => SignupState();
}

class SignupState extends State<Signup>{
  bool emailerror = false;
  bool passworderror = false;
  bool loginerror = false;
  bool password_visible = true;
  String msg1= '', msg2= '', emailmsg= '', passwordmsg = '';
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  signup() async {
    // Reset error states
    setState(() {
      passworderror = false;
      emailerror = false;
      passwordmsg = '';
      loginerror = false;
      msg1 = '';
      msg2 = '';
    });

    if (email.text.trim().isEmpty) {
      setState(() {
        emailmsg = 'Please enter your email';
        emailerror = true;
      });
      return;
    }

    if (password.text.trim().isEmpty) {
      setState(() {
        passwordmsg = 'Please enter your password';
        passworderror = true;
      });
      return;
    }

    try {
      // Create user
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );

      // Send verification email
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      FirebaseAuth.instance.signOut(); // Sign out user

      Get.snackbar(
        "Verify Email",
        "A verification link has been sent. Please check your inbox.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black,
        duration: Duration(seconds: 4),
        margin: EdgeInsets.all(12),
        borderRadius: 15,
      );

      Get.offAll(() => Work()); // Navigate to login (or root)

    } on FirebaseAuthException catch (e) {
      setState(() {
        msg1 = e.code;
        loginerror = true;
      });
    } catch (e) {
      setState(() {
        msg2 = e.toString();
        msg1 = "Something went wrong";
        loginerror = true;
      });
    }
  }

  /*   UI   */

  Widget build(BuildContext context){
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ Allows Scaffold to adjust for keyboard
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomRight,
            colors: [Color(0xfff4b6a3), Color(0xfffcb4fc)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: screenWidth*0.8,
              height: screenHeight*0.8, //  Fixed height to center content within container
              child: Stack( // Stack allows positioning Google button at bottom
                children: [
                  // Email & Password centered using Column
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: email,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.mail),
                            hintText: 'Enter valid email',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        /*print msg if email is not written*/
                        emailerror?Text(emailmsg,style: TextStyle(color: Colors.red),) :SizedBox(),

                        const SizedBox(height: 19),
                        TextField(
                          controller: password,
                          obscureText: password_visible,
                          obscuringCharacter: '*',
                          decoration: InputDecoration(
                            hintText: '        Enter password',
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: IconButton(
                              icon: Icon(
                                password_visible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  password_visible = !password_visible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        /*print msg if password is not written*/
                        passworderror? Text(passwordmsg,style: TextStyle(color: Colors.red),) : SizedBox(),

                        const SizedBox(height: 9),

                        /* Sign in button*/
                        ElevatedButton(
                            onPressed: ()=>signup(),
                            child: Container(
                              height: screenHeight*0.05,
                              width: screenWidth*0.18,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Center(
                                child: Text('Register',style : TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                )),
                              ),
                            )
                        ),

                        /*print message if invalid password or email*/
                        loginerror ? Text(
                          msg1.isNotEmpty ? msg1 : msg2,
                          style: TextStyle(color: Colors.red),
                        )
                            : SizedBox(),
                      ]
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}