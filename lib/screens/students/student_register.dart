// students log in here
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'polaroids.dart';
import '../extras/wrapper.dart';
import '../extras/text_details.dart';
import '../extras/submit_button.dart';
import 'package:class_list/code/extras.dart';
import 'package:class_list/code/queries.dart' as queries;

class StudentRegister extends StatefulWidget {
  @override
  _StudentRegisterState createState() => _StudentRegisterState();
}

class _StudentRegisterState extends State<StudentRegister> {
  String firstname, lastname, emailaddress, regno, programme, year;
  List<String> departments = [];
  List<String> yearsOfStudy = [
    'None',
    'I',
    'II',
    'III',
    'IV',
    'V',
    'VI',
    'VII'
  ];

  TextDetails years, programmes;

  void _firstname(String str) => setState(() => firstname = str);

  void _lastname(String str) => setState(() => lastname = str);

  void _email(String str) => setState(() => emailaddress = str);

  void _regno(String str) => setState(() => regno = str);

  /// What to render as pertaining list of departments
  Widget res;

  /// Set when department querying is successful
  bool isResult;

  /// Used during department querying
  bool isLoading;

  /// Message to be displayed in case something goes wrong
  String message;

  /// This will hold the department query results.
  /// Set as a map to ensure there is no repetition of results
  Map<dynamic, Map> data = Map<dynamic, Map>();

  /// Holds results of query
  QueryResult result;

  /// This class will get a list of all departments present
  /// independent of Query widget, enabling asynchronous querying
  void getDepartments([BuildContext context]) async {
    // run query
    GraphQLClient client = GraphQLProvider.of(context).value;
    await client
        .query(QueryOptions(
      document: queries.allDepartments,
      fetchPolicy: FetchPolicy.noCache,
    ))
        .then((onCompletedResult) {
      setState(() {
        // get result
        result = onCompletedResult;
        // clear previous results
        data.clear();
        // show progress spinner
        isLoading = true;
        // process result
        if (result == null) {
          isLoading = false;
        } else if (result.errors != null) {
          message = "Something went wrong";
          isLoading = false;
        } else if (result.loading || result.data == null)
          isLoading = true;
        else {
          isLoading = false;
          // get list of registered departments
          List edges = result.data['allDepartments']['edges'];
          List<String> depts = ['None'];
          edges.forEach((edge) => depts.add(edge['node']['name']));
          departments = depts;
        }

        isResult = true;
      });
    }).catchError((e) {
      print('Error: $e');
      setState(() => message = "Something went wrong");
    });
  }

  void _programme(program) {
    setState(() => programme = program);
    programmes = TextDetails(
      "Programme",
      dropdown: true,
      onChanged: _programme,
      value: programme,
      items: departments,
    );
  }

  void _year(yr) {
    setState(() => year = yr);
    years = TextDetails(
      "Year of Study",
      dropdown: true,
      items: yearsOfStudy,
      value: year,
      onChanged: _year,
    );
  }

  submit(BuildContext context) => setState(() {
        if (isStringEmpty(regno))
          showSnackbar("Please enter your registration number", context);
        else if (isStringEmpty(firstname))
          showSnackbar("Please enter your first name", context);
        else if (isStringEmpty(lastname))
          showSnackbar("Please enter your last name", context);
        else if (isStringEmpty(emailaddress))
          showSnackbar("Please enter your email address", context);
        else if (!validateEmail(emailaddress))
          showSnackbar("Please enter a valid email", context);
        else if (yearsOfStudy == null || yearsOfStudy.isEmpty)
          showSnackbar('Years not yet loaded. Please wait', context);
        else if (departments == null || departments.isEmpty)
          showSnackbar('Departments not yet loaded. Please wait', context);
        else if (year == yearsOfStudy.elementAt(0))
          showSnackbar('Year not selected', context);
        else if (programme == departments.elementAt(0))
          showSnackbar('Programme not selected', context);
        else {
          showSnackbar('Please wait...', context);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RegistrationImages(
                firstname,
                lastname,
                emailaddress,
                regno,
                programme,
                year,
                departments,
                yearsOfStudy,
              ),
            ),
          );
        }
      });

  @override
  void initState() {
    programme = 'None';
    year = 'None';
    years = TextDetails(
      "Year of Study",
      dropdown: true,
      onChanged: _year,
      items: yearsOfStudy,
      value: yearsOfStudy.elementAt(0),
    );
    message = "No results available";
    res = Container(
      child: Text(
        message,
        style: TextStyle(color: Color(0xFF47414d)),
      ),
    );
    isResult = false;
    isLoading = false;
    // A delayed future makes the code in the future run as soon as the currently running code finishes.
    // thus we can query for departments easily in initState
    Future.delayed(Duration.zero, () => getDepartments(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // change widget based on query result
    res = !isResult
        ? isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF47414d)),
                ),
              )
            : Center(
                child: Container(
                  child: Text(
                    message,
                    style: TextStyle(color: Color(0xFF47414d)),
                  ),
                ),
              )
        : TextDetails(
            "Programme",
            dropdown: true,
            onChanged: _programme,
            items: departments,
            value: programme,
          );
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
                Wrapper('Register for an account'),
                Padding(padding: EdgeInsets.all(10.0)),
                TextDetails(
                  "Registration Number",
                  hint: "e.g. A62/12345/2020",
                  keyboard: TextInputType.url,
                  onChanged: _regno,
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                TextDetails(
                  "First Name",
                  hint: "e.g. John",
                  onChanged: _firstname,
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                TextDetails(
                  "Last Name",
                  hint: "e.g. Doe",
                  onChanged: _lastname,
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                TextDetails(
                  "Email",
                  hint: "e.g. user@example.com",
                  keyboard: TextInputType.emailAddress,
                  onChanged: _email,
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                years,
                Padding(padding: EdgeInsets.all(10.0)),
                res,
                Padding(padding: EdgeInsets.all(10.0)),
                Builder(
                  builder: (BuildContext context) => SubmitButton(
                    'Continue',
                    entry: () => submit(context),
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
