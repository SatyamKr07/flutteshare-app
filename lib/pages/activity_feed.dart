import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/post_screen.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .document(currentUser.id)
        .collection('feedItems')
        .orderBy('timestamp', descending: false)
        .limit(50)
        .getDocuments();

    List<ActivityFeedItem> feedItem = [];

    snapshot.documents.forEach((doc) {
      //print('Activity Feed Item: ${doc.data}');
      feedItem.add(ActivityFeedItem.fromDocument(doc));
    });
    return feedItem;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.orange,
        appBar: header(context, titleText: 'Activity Feed'),
        body: Container(
            child: FutureBuilder<dynamic>(
          future: getActivityFeed(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              // TODO: do something with the data
              return ListView(
                children: snapshot.data,
              );
            } else if (snapshot.hasError) {
              // TODO: do something with the error
              return Text(snapshot.error.toString());
            }
            // TODO: the data is not ready, show a loading indicator
            return Center(child: CircularProgressIndicator());
          },
        )));
  }
}

Widget mediaPreview;
String activityItemText;

//modeling data and doing deserilazation of data both in stateless widget.
class ActivityFeedItem extends StatelessWidget {
  final String commentData;
  final String mediaUrl;
  final String postId;
  final Timestamp timestamp;
  final String type;
  final String userId;
  final String userProfileImage;
  final String username;

  ActivityFeedItem({
    this.commentData,
    this.mediaUrl,
    this.postId,
    this.timestamp,
    this.type,
    this.userId,
    this.userProfileImage,
    this.username,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      commentData: doc['commentData'],
      mediaUrl: doc['mediaUrl'],
      postId: doc['postId'],
      timestamp: doc['timestamp'],
      type: doc['type'],
      userId: doc['userId'],
      userProfileImage: doc['userProfileImage'],
      username: doc['username'],
    );
  }

  configureMediaPreview(context) {
    if (type == 'like' || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context), //pass context to use navigator,
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(mediaUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              )),
        ),
      );
    } else {
      mediaPreview = Text('');
    }
    if (type == 'like') {
      activityItemText = 'liked your post';
    } else if (type == 'comment') {
      activityItemText = 'replied: $commentData';
    } else if (type == 'follow') {
      activityItemText = 'is following you';
    } else {
      activityItemText = "Error : unknown type '$type'";
    }
  }

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: postId,
          userId: userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.orange[200],
        child: ListTile(
          onTap: () => showProfile(context, profileId: userId),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImage),
          ),
          title: GestureDetector(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(fontSize: 14.0, color: Colors.black),
                children: [
                  TextSpan(
                    text: username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' $activityItemText',
                  ),
                ],
              ),
            ),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}

showProfile(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
        profileId: profileId,
      ),
    ),
  );
}
