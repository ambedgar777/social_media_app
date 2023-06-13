import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/comment_button.dart';
import 'package:social_media_app/components/delete_button.dart';
import 'package:social_media_app/components/like_button.dart';
import 'package:social_media_app/components/comment.dart';
import 'package:social_media_app/helper/helper_methods.dart';

class WallPost extends StatefulWidget {
  final String message, user, postId, time;
  final List<String> likes;

  const WallPost({
    Key? key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
  }) : super(key: key);

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  //current firebase User;
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  //comment text controller
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  //toggle like
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    //access the document in the firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('Users').doc(widget.postId);

    if (isLiked) {
      //if a like is added then store user email to the firebase document
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email]),
      });
    } else {
      //if a like is remove then remove user email to the firebase document
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  // add a comment
  void addComment(String commentText) {
    FirebaseFirestore.instance
        .collection('User Posts')
        .doc(widget.postId)
        .collection('Comments')
        .add({
      'CommentText': commentText,
      'CommentedBy': currentUser.email,
      'CommentTime': Timestamp.now(), //modify it at the time of display
    });
  }

  //show a dialog to add a comment
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade300,
        title: const Text('Add Comment'),
        content: TextField(
          controller: _commentTextController,
          decoration: const InputDecoration(
            hintText: 'Leave a comment...',
          ),
        ),
        actions: [
          //cancel button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              //clear the text field
              _commentTextController.clear();
            },
            child: const Text('Cancel'),
          ),

          //save button
          TextButton(
            onPressed: () {
              addComment(_commentTextController.text);
              Navigator.pop(context);
              _commentTextController.clear();
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  //delete the post
  void deletePost() {
    //show a dialog box to ask for conformation if the user wanna delete the post
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.grey.shade300,
              title: const Text('Delete Post'),
              content: const Text('Are you sure, you want to delete this post?'),
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
                  onPressed: () async {
                    //delete the comment first from the firebase
                    //if you only delete the post then there will be comments stores in the database
                    final commentDocs = await FirebaseFirestore.instance
                        .collection('User Posts')
                        .doc(widget.postId)
                        .collection('Comments')
                        .get();

                    for (var doc in commentDocs.docs) {
                      await FirebaseFirestore.instance
                          .collection('User Posts')
                          .doc(widget.postId)
                          .collection('Comments')
                          .doc(doc.id)
                          .delete();
                    }

                    //then delete the wall post
                    FirebaseFirestore.instance
                        .collection('User Posts')
                        .doc(widget.postId)
                        .delete()
                        .then((value) => print('post deleted'))
                        .catchError(
                            (error) => print('Failed to delete post: ' + error));

                    //dismiss the dialog box
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25.0),
      margin: const EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //message and user emails
                  Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),

                  //user
                  Row(
                    children: [
                      Text(
                        widget.user,
                        style: const TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                      const Text(
                        '.',
                        style: TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                      Text(
                        widget.time,
                        style: const TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              //delete button
              if (widget.user == currentUser.email) ...[
                const SizedBox(width: 10),
                DeleteButton(onTap: deletePost),
              ],
            ],
          ),

          //Buttons
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Like
              Column(
                children: [
                  //like button
                  LikeButton(
                    onTap: toggleLike,
                    isLiked: isLiked,
                  ),
                  //like count
                  const SizedBox(height: 5),
                  Text(
                    widget.likes.length.toString(),
                    style: const TextStyle(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 10),

              //comment
              Column(
                children: [
                  //comment button
                  CommentButton(
                    onTap: showCommentDialog,
                  ),

                  const SizedBox(height: 5),
                  //comment count
                  const Text(
                    '0',
                    style: TextStyle(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),
          //comments under the post
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('User Posts')
                .doc(widget.postId)
                .collection('Comments')
                .orderBy('CommentTime', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map<Widget>((doc) {
                  final commentData = doc.data() as Map<String, dynamic>;

                  return Comment(
                    user: commentData['CommentedBy'],
                    text: commentData['CommentText'],
                    time: formatDate(
                      commentData['CommentTime'],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
