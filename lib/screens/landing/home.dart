// this is the home page
import 'package:flutter/material.dart';
import 'package:class_list/code/line.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                color: Colors.grey[100],
                width: double.infinity,
                child: Card(
                  elevation: 0.0,
                  color: Colors.grey[100],
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'Class Attendance System',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10.0),
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 2,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/uon-logo.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Text(
                        'Welcome to the Class Attendance System',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
                    Container(
                      foregroundDecoration:
                          new StrikeThroughDecoration(color: Colors.white),
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Center(
                        child: Text(
                          'Hello there!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
