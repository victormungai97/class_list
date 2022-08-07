// this holds the grey field at the top
import 'package:flutter/material.dart';
import 'package:class_list/code/line.dart';

class Wrapper extends StatelessWidget {
  final String title;

  Wrapper(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      color: Colors.grey[100],
      width: double.infinity,
      foregroundDecoration: StrikeThroughDecoration(color: Colors.grey[100]),
      child: Card(
        elevation: 0.0,
        color: Colors.grey[100],
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.0,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
