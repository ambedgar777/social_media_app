import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/drawer.dart';
import 'package:social_media_app/components/my_text_field.dart';
import 'package:social_media_app/components/wall_posts.dart';
import 'package:social_media_app/helper/helper_methods.dart';
import 'package:social_media_app/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //current user
  final currentUser = FirebaseAuth.instance.currentUser!;
  //Message Text Controller
  final textController = TextEditingController();

  //Navigate to Profile Page
  void goToProfilePage() {
    Navigator.pop(context);

    //go to new Page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey.shade900,
        elevation: 0.0,
        title: const Text(
          'Social Media App',
          style: TextStyle(
            letterSpacing: 1,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onLogoutTap: signOut,
      ),
      body: Center(
        child: Column(
          children: [
            //The Wall
            Expanded(
                child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .orderBy('TimeStamp', descending: false)
                  .snapshots(),
              builder: (context, snapshots) {
                if (snapshots.hasData) {
                  return ListView.builder(
                    itemCount: snapshots.data!.docs.length,
                    itemBuilder: (context, index) {
                      //get the message
                      final post = snapshots.data!.docs[index];
                      return WallPost(
                        message: post['Message'],
                        user: post['UserEmail'],
                        postId: post.id,
                        likes: List<String>.from(post['Likes'] ?? []),
                        time: formatDate(post['TimeStamp']),
                      );
                    },
                  );
                } else if (snapshots.hasError) {
                  return Center(
                    child: Text(
                      'Errors: ${snapshots.hasError}',
                    ),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            )),

            //Post Message
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  Expanded(
                    child: MyTextFields(
                        hintText: 'Send a message',
                        obscureText: false,
                        controller: textController),
                  ),
                  IconButton(
                    onPressed: postMessage,
                    icon: const Icon(
                      Icons.arrow_circle_up,
                    ),
                  ),
                ],
              ),
            ),

            //Logged In as
            Text(
              currentUser.email!.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  //Sign out method
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void postMessage() {
    //only post if there is something in the post field
    if (textController.text.isNotEmpty) {
      //store the data
      FirebaseFirestore.instance.collection('Users').add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
      //clear the field after posting
      setState(() {
        textController.clear();
      });
    }
  }
}
