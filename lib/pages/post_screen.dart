import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';

class PostScreen extends StatelessWidget {
  final String postId;
  final String userId;

  PostScreen({this.userId, this.postId});

  @override
  Widget build(BuildContext context) {
    print("postId: $postId");
    return FutureBuilder<dynamic>(
      future: postsRef
          .document(userId)
          .collection('userPosts')
          .document(postId)
          .get(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        print('qqq');
        print("postId yaha: $postId");

        Post post = Post?.fromDocument(snapshot?.data);
        print('yaha hoon');
        print("postId yahaaaaaaa: $postId");

        return Center(
          child: Scaffold(
            appBar: header(context, titleText: post?.description),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
