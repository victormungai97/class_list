// students log in here
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../extras/wrapper.dart';
import '../extras/text_details.dart';
import '../extras/submit_button.dart';
import 'package:class_list/code/extras.dart';
import 'package:class_list/code/mutations.dart' as mutations;

class StudentLogin extends StatefulWidget {
  @override
  _StudentLoginState createState() => _StudentLoginState();
}

class _StudentLoginState extends State<StudentLogin> {
  String regno, message = '', token = '';
  int status = 0;

  void _regno(String str) => setState(() => regno = str);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Wrapper('Student Login'),
              Padding(padding: EdgeInsets.all(20.0)),
              TextDetails(
                "Registration Number",
                hint: "e.g. A62/12345/2020",
                keyboard: TextInputType.url,
                onChanged: _regno,
              ),
              Padding(padding: EdgeInsets.all(10.0)),
              Builder(
                builder: (BuildContext context) => Mutation(
                  options: MutationOptions(
                    document: mutations.studentLogin,
                    fetchPolicy: FetchPolicy.noCache,
                  ),
                  builder: (RunMutation studentLogin, QueryResult result) {
                    try {
                      if (result.errors != null) {
                        print(result.errors.toString());
                        return Text("Something went wrong. ${result.errors}");
                      }

                      if (result.loading) {
                        return CircularProgressIndicator();
                      }

                      return SubmitButton(
                        'Login',
                        entry: () => complete(context, studentLogin),
                      );
                    } catch (e) {
                      print(e.toString());
                      return SubmitButton(
                        'Login',
                        entry: () => complete(context, studentLogin),
                      );
                    }
                  },
                  onCompleted: (dynamic completedResult) {
                    print('Result:\t$completedResult');
//                    status = completedResult.data['studentLogin']['status'];
//                    message = completedResult.data['studentLogin']['message'];
//                    token =
//                        completedResult.data['studentLogin']['access_token'];
//                    showSnackbar(message, context);
//                    print('Token: \t$token');
                  },
                ),
              ),
              Padding(padding: EdgeInsets.all(10.0)),
              // TODO: We shall implement student registration for iOS once we have a MacOS so as to enable Firebase ML configurations
              Platform.isAndroid
                  ? SubmitButton(
                      'Register',
                      color: Colors.lightBlue,
                      entry: () =>
                          Navigator.of(context).pushNamed('/student_register'),
                    )
                  : SizedBox(width: 0.0),
              // GestureDetector(
              //   child: Text(
              //     'Register here',
              //     style: TextStyle(
              //       color: Color(0xFF428BCA),
              //       decoration: TextDecoration.underline,
              //     ),
              //   ),
              //   onTap: () =>
              //       Navigator.of(context).pushNamed('/student_register'),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  complete(BuildContext context, RunMutation studentLogin) {
    if (isStringEmpty(regno))
      showSnackbar("Please enter your registration number", context);
    else {
      showSnackbar('Please wait...', context);
      studentLogin(
        <String, dynamic>{
          "regno": regno,
        },
      );
    }
  }
}
