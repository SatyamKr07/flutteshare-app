import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String bio;
  final String email;
  final String displayName;
  final String id;
  final String photoUrl;
  final String username;

  User(
      {this.bio,
      this.email,
      this.displayName,
      this.id,
      this.photoUrl,
      this.username});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      bio: doc['bio'],
      email: doc['email'],
      displayName: doc['displayName'],
      photoUrl: doc['photoUrl'],
      username: doc['username'],
    );
  }
}
