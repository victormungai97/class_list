// here, staff member can enter email address if they forgot their password
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:class_list/code/extras.dart';
import '../extras/submit_button.dart';
import '../extras/wrapper.dart';
import '../extras/text_details.dart';
import 'package:class_list/code/mutations.dart' as mutations;

class StaffPasswordReset extends StatefulWidget {
  @override
  _StaffPasswordResetState createState() => _StaffPasswordResetState();
}

class _StaffPasswordResetState extends State<StaffPasswordReset> {
  String staffId, message;
  int status;

  void _id(String id) => setState(() => staffId = id);

  submit(BuildContext context, RunMutation resetPassword) => setState(() {
        if (isStringEmpty(staffId))
          showSnackbar("Please enter the staff ID", context);
        else {
          showSnackbar("Please wait...", context);
          resetPassword(<String, dynamic>{"staffId": staffId});
        }
      });

  @override
  void initState() {
    super.initState();
    staffId = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pushNamed('/first'),
        ),
        title: Text(
          'Class Attendance System',
          style: TextStyle(
            color: Colors.teal[800],
            fontWeight: FontWeight.bold,
            fontSize: 17.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Wrapper('Request Password Reset'),
                Padding(padding: EdgeInsets.all(20.0)),
                TextDetails(
                  "Staff ID",
                  hint: "e.g. A62/0001",
                  keyboard: TextInputType.url,
                  onChanged: _id,
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                Builder(
                  builder: (BuildContext context) => Mutation(
                    options: MutationOptions(
                      document: mutations.resetStaffPassword,
                      fetchPolicy: FetchPolicy.noCache,
                    ),
                    builder: (
                      RunMutation resetPassword,
                      QueryResult result,
                    ) {
                      try {
                        if (result.errors != null) {
                          print(result.errors.toString());
                          return Text("Something went wrong. ${result.errors}");
                        }

                        if (result.loading) {
                          return CircularProgressIndicator();
                        }

                        return SubmitButton(
                          'Reset Password',
                          entry: () => submit(context, resetPassword),
                        );
                      } catch (e) {
                        print(e.toString());
                        return SubmitButton(
                          'Reset Password',
                          entry: () => submit(context, resetPassword),
                        );
                      }
                    },
                    onCompleted: (dynamic onCompleteResult) {
                      print('Data:\t$onCompleteResult');
//                      status =
//                          onCompleteResult.data['resetStaffPassword']['status'];
//                      message = onCompleteResult.data['resetStaffPassword']
//                          ['message'];
//                      showSnackbar(message, context);
                      // if (status == 0)
                      //   Navigator.of(context).pushReplacementNamed('/');
                    },
                  ),
                ),
                Padding(padding: EdgeInsets.all(10.0)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
