//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/chats/main_screen.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';

// import '../widgets/header.dart';
// import '../widgets/progress.dart';

final userRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final User currentUser;
  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    super.initState();
    getTimeline() async {}
  }

  @override
  Widget build(context) {
    return Scaffold(
      //appBar: header(context, isAppTitle: true,isAction: true),
      appBar: AppBar(
        title: Text('Flutter Share'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.book),
            onPressed: () {
              print("userId");
              print(currentUser.id);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MainScreen(currentUserId: currentUser.id),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              print("userId");
              print(currentUser.id);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MainScreen(currentUserId: currentUser.id),
                ),
              );
            },
            textColor: Colors.white,
            color: Colors.blueAccent,
            disabledColor: Colors.grey,
            disabledTextColor: Colors.white,
            highlightColor: Colors.orangeAccent,
            elevation: 4.0,
            child: Text('Click to chat'),
          ),
          // RefreshIndicator(
          //     //onRefresh: () => getTimeline(),
          //     //child: buildTimeline(),
          //     )
        ],
      ),
    );
  }
}
