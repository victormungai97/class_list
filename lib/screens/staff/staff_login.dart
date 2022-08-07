// staff members log in here
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../extras/wrapper.dart';
import '../extras/text_details.dart';
import '../extras/submit_button.dart';
import 'package:class_list/code/extras.dart';
import 'package:class_list/code/mutations.dart' as mutations;

class StaffLogin extends StatefulWidget {
  @override
  _StaffLoginState createState() => _StaffLoginState();
}

class _StaffLoginState extends State<StaffLogin> {
  String staffId, password;

  void _staffID(String str) => setState(() => staffId = str);

  void _password(String str) => setState(() => password = str);

  submit(BuildContext context, RunMutation staffLogin) => setState(() {
        if (isStringEmpty(staffId))
          showSnackbar("Please enter the staff ID", context);
        else if (isStringEmpty(password))
          showSnackbar("Please enter the password", context);
        else if (password.length < 6 || password.length > 14)
          showSnackbar(
              "Password should be between 6 to 14 characters", context);
        else {
          showSnackbar("Please wait...", context);
          staffLogin({
            "staffID": staffId,
            "password": password,
          });
        }
      });

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
              Wrapper('Staff Login'),
              Padding(padding: EdgeInsets.all(20.0)),
              TextDetails(
                "Staff ID",
                hint: "e.g. A62/0001",
                keyboard: TextInputType.url,
                onChanged: _staffID,
              ),
              Padding(padding: EdgeInsets.all(10.0)),
              TextDetails(
                'Password',
                hint: 'Password',
                obscure: true,
                onChanged: _password,
              ),
              Padding(padding: EdgeInsets.all(10.0)),
              Builder(
                builder: (BuildContext context) => Mutation(
                  options: MutationOptions(
                    // this is the mutation string
                    document: mutations.staffLogin,
                    fetchPolicy: FetchPolicy.noCache,
                  ),
                  builder: (RunMutation staffLogin, QueryResult result) {
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
                        entry: () => submit(context, staffLogin),
                      );
                    } catch (e) {
                      return Text('Something went wrong\n${e.toString()}');
                    }
                  },
                  // you can update the cache based on results
                  update: (Cache cache, QueryResult result) {
                    return cache;
                  },
                  onCompleted: (dynamic resultData) {
                    print("$resultData");
                  },
                ),
              ),
              Padding(padding: EdgeInsets.all(10.0)),
              GestureDetector(
                child: Text(
                  "Forgot password?",
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
                onTap: () =>
                    Navigator.of(context).pushNamed('/staff_reset_password'),
              ),
              Padding(padding: EdgeInsets.all(10.0)),
            ],
          ),
        ),
      ),
    );
  }
}
