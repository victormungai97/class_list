// This is the first screen
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home.dart' as home;
import '../students/student_login.dart' as student_login;
import '../staff/staff_login.dart' as staff_login;

/// We use a stateful widget as there will be a change in state(internal data)
/// when the tab is changed
class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

// ticker provider enables navigation with animation
class _FirstScreenState extends State<FirstScreen>
    with SingleTickerProviderStateMixin {
  // color for selected bottom navigation bar icon
  final selected = Color(0xFF47414d);

  // Manages the state required by TabBar and a TabBarView.
  TabController controller;

  // keep track of which tab we are on
  int _index;

  // list of widgets that are to be rendered based on the currently selected tab.
  List<Widget> _children = <Widget>[
    home.HomePage(),
    staff_login.StaffLogin(),
    student_login.StudentLogin(),
  ];

  @override
  void initState() {
    super.initState();
    // length is the number of tabs
    controller = TabController(vsync: this, length: 3);
    controller.addListener(() => setState(() => _index = controller.index));
    _index = 0;
  }

  @override
  void dispose() {
    // release resources once done
    controller.dispose();
    super.dispose();
  }

  /// This method is called when the user is on landing screen & presses the back button
  Future<bool> _confirmPop(BuildContext context) {
    return showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(
              'Exit app',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            content: Text(
              'You are about to exit this app',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  if (Theme.of(context).platform == TargetPlatform.android)
                    SystemNavigator.pop();
                  else if (Theme.of(context).platform == TargetPlatform.iOS)
                    exit(0);
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.teal[300],
                    fontSize: 18.0,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                    color: Colors.teal[300],
                    fontSize: 18.0,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _confirmPop(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Class Attendance System',
            style: TextStyle(
              color: Colors.teal[800],
              fontWeight: FontWeight.bold,
              fontSize: 17.0,
            ),
          ),
        ),

        // place tabs at the bottom of the screen
        // Material is used as TabBar doesn't have property for setting color
        bottomNavigationBar: Material(
          color: Colors.grey[800],
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (int index) {
              controller.animateTo(index);
              setState(() => this._index = index);
            },
            type: BottomNavigationBarType.shifting,
            items: [
              // home page
              BottomNavigationBarItem(
                title: Text(
                  'Home',
                  style: TextStyle(color: selected, fontSize: 14.0),
                ),
                icon: _index == 0
                    ? Icon(Icons.home, color: selected)
                    : Icon(Icons.home, color: Colors.black),
              ),
              // staff login page
              BottomNavigationBarItem(
                title: Text(
                  'Staff',
                  style: TextStyle(color: selected, fontSize: 14.0),
                ),
                icon: _index == 1
                    ? Icon(Icons.wc, color: selected)
                    : Icon(Icons.wc, color: Colors.black),
              ),
              // student login page
              BottomNavigationBarItem(
                title: Text(
                  'Student',
                  style: TextStyle(color: selected, fontSize: 14.0),
                ),
                icon: _index == 2
                    ? Icon(Icons.school, color: selected)
                    : Icon(Icons.school, color: Colors.black),
              ),
            ],
          ),
        ),

        // set up the various tab pages in this body
        body: Material(
          color: Colors.white,
          child: TabBarView(
            controller: controller,
            children: _children,
          ),
        ),
      ),
    );
  }
}
