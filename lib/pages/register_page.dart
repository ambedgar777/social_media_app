import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/my_button.dart';
import 'package:social_media_app/components/my_text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //logo
                  const Icon(
                    Icons.local_cafe_rounded,
                    size: 100,
                    color: Colors.black,
                  ),

                  //welcome back message
                  const SizedBox(height: 50),
                  Text(
                    'Please create your account!',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),

                  //sign in text field
                  const SizedBox(height: 25),
                  MyTextFields(
                      hintText: 'Email',
                      obscureText: false,
                      controller: emailTextController),

                  //password text field
                  const SizedBox(height: 10),
                  MyTextFields(
                      hintText: 'Password',
                      obscureText: true,
                      controller: passwordTextController),

                  //confirm password
                  const SizedBox(height: 10),
                  MyTextFields(
                      hintText: 'Confirm Password',
                      obscureText: true,
                      controller: confirmPasswordTextController),

                  //sign up button
                  const SizedBox(height: 10),
                  MyButton(text: 'Sign Up', onTap: signUp),
                  //register now
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          'Login Now',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  signUp() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      ),
    );
    if (passwordTextController.text != confirmPasswordTextController.text) {
      Navigator.pop(context);
      //show Error Message
      displayMessage('Password does not match');
      return;
    }
    //try catch
    try {
      //create the user
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );
      //after creating the user, create a new document, call it users
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.email)
          .set({
        'username': emailTextController.text.split('@')[0], //initial username
        'bio': 'Empty Bio...' //initial empty bio
        //add any additional fields if need
      });

      //pop the circle after user has been created
      if (context.mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      //pop loading circle
      Navigator.pop(context);
      displayMessage(e.code);
    }
  }

  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
