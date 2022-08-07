// setting of paths to different screens happens here
import 'package:flutter/material.dart';
import '../screens/landing/first.dart';
import '../screens/students/student_register.dart';
import '../screens/staff/staff_reset_password.dart';

// create paths
final routes = <String, WidgetBuilder>{
  '/': (_) => FirstScreen(), // default route
  '/first': (_) => FirstScreen(),
  '/student_register': (_) => StudentRegister(),
  '/staff_reset_password': (_) => StaffPasswordReset(),
};
