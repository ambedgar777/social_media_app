import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/text_box.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //current user
  final currentUser = FirebaseAuth.instance.currentUser!;

  //all users
  final usersCollection = FirebaseFirestore.instance.collection('Users');

  //edit field method
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade200,
        title: Text(
          'Edit $field',
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.black54),
          decoration: InputDecoration(
            hintText: 'Enter new $field',
            hintStyle: const TextStyle(
              color: Colors.black54,
            ),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          //cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ),

          //save button
          TextButton(
            onPressed: () => Navigator.of(context).pop(newValue),
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
    //update the code into the firestore
    if (newValue.trim().length > 0) {
      //only update if there is something in the field
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.grey.shade900,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(currentUser.email)
              .snapshots(),
          builder: (context, snapshot) {
            //get the user data
            if (snapshot.hasData) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              return ListView(
                children: [
                  const SizedBox(height: 50),
                  //profile pic
                  const Icon(
                    Icons.person,
                    size: 72,
                  ),

                  const SizedBox(height: 10),
                  //user email
                  Text(
                    currentUser.email!.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(
                    height: 50,
                  ),
                  //user details
                  const Padding(
                    padding: EdgeInsets.only(left: 25.0),
                    child: Text(
                      'MY DETAILS',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  //username
                  MyTextBox(
                    text: userData['username'],
                    sectionName: 'username',
                    onTap: () => editField('username'),
                  ),

                  //bio
                  MyTextBox(
                    text: userData['bio'],
                    sectionName: 'bio',
                    onTap: () => editField('bio'),
                  ),

                  //user posts
                  const SizedBox(height: 50),
                  const Padding(
                    padding: EdgeInsets.only(left: 25.0),
                    child: Text(
                      'MY POSTS',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }
}
