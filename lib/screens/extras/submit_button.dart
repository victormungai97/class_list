// Submission button
import 'package:flutter/material.dart';

/// This is the button used to login or register into the attendance system via mobile app
/// Ensure that you provide the message to be displayed on the button
/// And the function to be executed
class SubmitButton extends StatelessWidget {
  final String text;
  final Function entry;
  final Color color;

  SubmitButton(this.text, {this.entry, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 + 20.0,
      height: 45.0,
      child: RaisedButton(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 17.0),
        ),
        color: color ?? Color(0xFF5CB85C),
        onPressed: entry ?? () {},
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(30.0),
        ),
        elevation: 5.0,
      ),
    );
  }
}
