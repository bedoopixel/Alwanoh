import 'package:admin_panel/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Auth.dart';
import 'Home_Page.dart';
import 'custom_scaffold.dart';




class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
final FirebaseAuthServiec _auth = FirebaseAuthServiec();

  TextEditingController emailcontroller = new TextEditingController();
  TextEditingController passwordlcontroller = new TextEditingController();

@override
void dispose(){
  emailcontroller.dispose();
  passwordlcontroller.dispose();
  super.dispose();
}

  final _formSignInKey = GlobalKey<FormState>();
  bool rememberPassword = true;
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          SizedBox(
            height: 0,
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 80.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0.0),
                  topRight: Radius.circular(0.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: Styles.customColor,
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      TextFormField(
                        controller: emailcontroller,
                        style: TextStyle(color: Styles.customColor,),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Email',style: TextStyle(color: Styles.customColor,),),
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(
                            color: Styles.customColor,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Styles.customColor, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Styles.customColor, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Styles.customColor, // Border color when focused
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 25.0,
                      ),
                      TextFormField(
                        style: TextStyle(color: Styles.customColor,),
                        controller: passwordlcontroller,
                        cursorColor: Styles.customColor,

                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Password',style: TextStyle(color: Styles.customColor,),),
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(
                            color: Styles.customColor,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Styles.customColor,// Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Styles.customColor,// Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Styles.customColor,))
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      GestureDetector(
                        onTap:_sginin,
                        child: Container(
                          width: 450,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Styles.customColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            )
                          ),
                          child: Center(child: Text("Sign in",style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),)),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),

                      const SizedBox(
                        height: 25.0,
                      ),
                      // don't have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have an account? ',
                            style: TextStyle(
                              color: Styles.customColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) =>  AdminHomePage(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Styles.customColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
void _sginin()async{
  String email=emailcontroller.text;
  String password = passwordlcontroller.text;

  User? user = await _auth.sginINWithEmailAndPAssword(email, password);
  if(user!=null)
  {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (e) =>  AdminHomePage(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sginin Done")));
  }
  else {
    print("no no no");
  }
}
}
