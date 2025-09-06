import 'package:fare_calculator/signup.dart';
import 'package:fare_calculator/working.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget{
  LoginPageState createState()=> LoginPageState();
}
class LoginPageState extends State<LoginPage>{
    bool emailerror = false;
    bool passworderror = false;
    bool loginerror = false;
    bool password_visible = true;

    String msg1= '', msg2= '', emailmsg= '', passwordmsg = '';
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();
    double _opacity = 0.0;
    @override
    void initState() {
      super.initState();

      Future.delayed(Duration(milliseconds: 200), () {
        setState(() {
          _opacity = 1.0;
        });
      });
    }

    login() async {
      setState(() {
        passworderror = false;
        emailerror = false;
        loginerror = false;
        passwordmsg = '';
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
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text.trim(),
        );

        // ✅ Navigate to Work page if login successful
        Get.off(() => Work());

      } on FirebaseAuthException catch (e) {
        print('FirebaseAuthException: ${e.code} - ${e.message}');
        setState(() {
          msg1 = e.code;
          loginerror = true;
        });
      } catch (e) {
        setState(() {
          msg1 = 'Something went wrong';
          msg2 = e.toString();
          loginerror = true;
        });
      }
    }




    @override
    Widget build(BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      return Scaffold(
        resizeToAvoidBottomInset: true, // ✅ Allows Scaffold to adjust for keyboard
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'Forgot Password',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: ()=> Get.to(()=>Signup()),
                                child: const Text(
                                  'New user? Register',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                         const SizedBox(),

                           /* Sign in button*/
                           ElevatedButton(
                              onPressed: ()=>login(),
                              child: Container(
                                height: 40,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const Center(
                                  child: Text('Sign In',style : TextStyle(
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

                      // ✅ Google Button pinned at bottom using Align
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Google button tapped')),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 20), // ✅ adds spacing from bottom
                            height: screenHeight*0.05,
                            width: screenWidth*0.45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Continue With ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                    width: 50,
                                    child: Image.asset('assets/Images/google.png'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

}
