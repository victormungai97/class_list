// extras found here
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// this is the function to show a snackbar
showSnackbar(msg, context) =>
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(msg)));

// this is a function to show a Toast
showToast(msg) => Fluttertoast.showToast(msg: msg);

bool validateEmail(String email) {
  RegExp regExp = new RegExp(
    r"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}",
    caseSensitive: false,
    multiLine: false,
  );
  return regExp.hasMatch(email);
}

bool isStringEmpty(String str) =>
    str == null || str == '' || str.length == 0 ? true : false;
