//import 'dart:html';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String username;

  submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      SnackBar snackbar = SnackBar(content: Text('Welcome $username'));
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
    //pass value of username
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: header(context,
            titleText: 'Set up your Profile', removeBackButton: true),
        body: ListView(
          children: <Widget>[
            Container(
                child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Create a username",
                      style: TextStyle(
                        fontSize: 25.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Roboto",
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      autovalidate: true,
                      // final _formKey=GlobalKey<FormState>(); paste it below extend state
                      child: TextFormField(
                        validator: (val) {
                          if (val.isEmpty || val.trim().length < 3) {
                            return 'Username too short';
                          } else if (val.trim().length > 12) {
                            return 'Username too long';
                          } else {
                            return null;
                          }
                        },

                        onSaved: (val) => username = val,
                        style: TextStyle(color: Colors.black),
                        obscureText:
                            false, // Use true to secure text for passwords.
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(),
                          border: OutlineInputBorder(),
                          hintText: 'Must be atleast 3 characters',
                          hintStyle: TextStyle(color: Colors.grey),
                          labelText: "Username",
                          labelStyle: TextStyle(color: Colors.black),
                        ), //textInputDecoration,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => submit(),
                  child: Container(
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Roboto",
                        ),
                      ),
                    ),
                    width: 260.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                      // image: DecorationImage(
                      //   image: AssetImage('assets/images/google_signin_button.png'),
                      //   fit: BoxFit.cover,
                      // ),
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                  ),
                )
              ],
            ))
          ],
        ));
  }
}
