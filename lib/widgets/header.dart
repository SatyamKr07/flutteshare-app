import 'package:flutter/material.dart';

AppBar header(context,
    {bool isAppTitle = false, String titleText, removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      isAppTitle ? "Flutter Share" : titleText,
      style: TextStyle(
        fontSize: isAppTitle ? 50.0 : 20.0,
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontFamily: isAppTitle ? "Signatra" : '',
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
