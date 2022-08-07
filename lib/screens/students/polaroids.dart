// here,we have the images used for registration
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';

import '../extras/wrapper.dart';
import '../extras/text_details.dart';
import '../extras/submit_button.dart';
import 'package:class_list/code/queries.dart' as queries;
import 'package:class_list/code/mutations.dart' as mutations;
import 'package:class_list/code/extras.dart';

class _CustomSnackbar extends SnackBar {
  final String message;
  final Function function;
  final BuildContext context;
  final int index;
  final bool act;

  _CustomSnackbar({
    Key key,
    this.message,
    this.function,
    this.context,
    this.index,
    this.act,
  }) : super(
          key: key,
          // action: act == true || act == null
          //     ? SnackBarAction(
          //         label: 'RETAKE',
          //         onPressed: () {
          //           Scaffold.of(context).hideCurrentSnackBar();
          //           function(context, index);
          //         })
          //     : null,
          content: Text(message),
        );
}

/// This class shall handle the taking of a student's images and on successful
/// completion, shall then facilitate the addition of the student via a [Mutation]
/// It receives the details as entered by a student in the previous page
class RegistrationImages extends StatefulWidget {
  final String firstname, lastname, emailaddress, regno, programme, year;
  final List<String> departments, yearsOfStudy;

  RegistrationImages(
    this.firstname,
    this.lastname,
    this.emailaddress,
    this.regno,
    this.programme,
    this.year,
    this.departments,
    this.yearsOfStudy,
  );

  @override
  _RegistrationImagesState createState() => _RegistrationImagesState();
}

class _RegistrationImagesState extends State<RegistrationImages> {
  String firstname,
      lastname,
      emailaddress,
      regno,
      programme,
      year,
      message = '';
  Map<String, File> images;
  int status = 0, numOfImages = 10;

  List<String> departments, yearsOfStudy;

  TextDetails years, programmes;

  void _firstname(String str) => setState(() => firstname = str);

  void _lastname(String str) => setState(() => lastname = str);

  void _email(String str) => setState(() => emailaddress = str);

  void _regno(String str) => setState(() => regno = str);

  void _programme(program) {
    setState(() => programme = program);
    programmes = TextDetails(
      "Programme",
      dropdown: true,
      onChanged: _programme,
      value: program,
      items: departments,
    );
  }

  void _year(yr) {
    setState(() => year = yr);
    years = TextDetails(
      "Year of Study",
      dropdown: true,
      items: yearsOfStudy,
      value: yr,
      onChanged: _year,
    );
  }

  /// What to render as pertaining list of departments
  Widget res;

  /// Set when department querying is successful
  bool isResult;

  /// Used during department querying
  bool isLoading;

  /// Message to be displayed in case something goes wrong
  String msg;

  /// This will hold the department query results.
  /// Set as a map to ensure there is no repetition of results
  Map<dynamic, Map> data = Map<dynamic, Map>();

  /// Holds results of query
  QueryResult result;

  /// Here, asynchronously query for the number of images that a students needs to submit
  /// and build the page body around the result
  void _buildBody([BuildContext context]) async {
    // run query
    GraphQLClient client = GraphQLProvider.of(context).value;
    await client
        .query(QueryOptions(
      document: queries.numOfImages, // query string
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
          msg = "Something went wrong";
          isLoading = false;
        } else if (result.loading || result.data == null)
          isLoading = true;
        else {
          isLoading = false;
          // get no of images needed for registration
          numOfImages = result.data["numberImages"];
        }

        isResult = true;
      });
    }).catchError((e) {
      print('Error: $e');
      setState(() => message = "Something went wrong");
    });
  }

  /// Here, we shall render the body of the page,
  /// consisting of the GridView for images and the submission and review buttons
  Widget polaroidBody() {
    return Column(
      children: <Widget>[
        Wrapper('Select your images'),
        Expanded(
          child: Builder(
            builder: (BuildContext context) => Container(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // this sets number of columns
                ),
                itemBuilder: (_, int index) => _buildGridItems(context, index),
                // set number of grid items
                itemCount: numOfImages,
              ),
            ),
          ),
        ),
        Padding(padding: EdgeInsets.all(10.0)),
        Builder(
          builder: (BuildContext context) => _reviewDetails(context),
        ),
        Padding(padding: EdgeInsets.all(10.0)),
        Builder(
          builder: (BuildContext context) => Mutation(
            options: MutationOptions(
              document: mutations.registerStudent, // mutation string
              fetchPolicy: FetchPolicy.noCache,
            ),
            builder: (
              RunMutation registerStudent,
              QueryResult registerStudentResult,
            ) {
              try {
                if (registerStudentResult.errors != null) {
                  print(registerStudentResult.errors.toString());
                  return Text(
                      "Something went wrong. ${registerStudentResult.errors}");
                }

                if (registerStudentResult.loading) {
                  return CircularProgressIndicator();
                }

                return SubmitButton(
                  'Complete',
                  entry: () => complete(context, registerStudent),
                );
              } catch (e) {
                print(e.toString());
                return SubmitButton(
                  'Complete',
                  entry: () => complete(context, registerStudent),
                );
              }
            },
            onCompleted: (dynamic onCompleteResult) {
              print('Data: ${onCompleteResult.data}');
              status = onCompleteResult.data['newStudent']['status'];
              message = onCompleteResult.data['newStudent']['message'];
              showSnackbar(message, context);
              if (status == 0) Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ),
        Padding(padding: EdgeInsets.all(10.0)),
      ],
    );
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<String> get _createDirectory async {
    final path = await _localPath;
    final Directory dir = Directory('$path/Documents');
    // check if dir exists
    dir.exists().then((isThere) {
      isThere
          ? print('Exists')
          : // The created directory is returned as a Future.
          dir.create(recursive: true).then((Directory directory) {
              print(directory.path);
            });
    });
    return dir.path;
  }

  String encodeZipFile(File zipFile) {
    List<int> imageBytes = zipFile.readAsBytesSync();
    return base64Encode(imageBytes);
  }

  complete(BuildContext context, RunMutation registerStudent) async {
    var encoder = ZipFileEncoder();
    final dir = await _createDirectory;
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyyMMdd_HHmmssSSS').format(now);
    String zipPath = '$dir/$formattedDate.zip';
    if (images.length < numOfImages)
      Scaffold.of(context).showSnackBar(
        _CustomSnackbar(
          message: '$numOfImages images required',
          act: false,
        ),
      );
    else {
      encoder.create(zipPath);
      bool zipped = true;
      images.forEach((pos, img) {
        if (img == null) {
          showSnackbar('Image no. ${int.parse(pos) + 1} missing', context);
          zipped = false;
        } else
          encoder.addFile(img);
      });
      encoder.close();
      if (zipped) {
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
        else if (year == yearsOfStudy.elementAt(0))
          showSnackbar('Year not selected', context);
        else if (programme == departments.elementAt(0))
          showSnackbar('Programme not selected', context);
        else {
          showSnackbar('Please wait...', context);
          registerStudent(
            <String, dynamic>{
              'regno': regno,
              'name': '$firstname $lastname',
              'email': emailaddress,
              'year': year,
              'department': programme,
              'zipFile': encodeZipFile(File(zipPath)),
            },
          );
        }
      } else {
        try {
          // if there is a null image, delete existing zip file
          File(zipPath).delete();
        } catch (e) {
          showSnackbar('Something went wrong', context);
          print(e);
        }
      }
    }
  }

  pickerCamera(BuildContext context, int index) async {
    // call camera and wait for the image file, hence Future file
    File img = await ImagePicker.pickImage(source: ImageSource.camera);
    // update UI only when an image has been selected
    // if (img != null)
    //   img =
    //       await detectFace(img, context, index).catchError((err) => print(err));
    setState(() => images['$index'] = img);
  }

  Future<File> detectFace(File img, BuildContext context, int index) async {
    File result;
    List<Face> faces = [];
    // holds image data ready for the recognition process by cloud and on-device detectors
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(img);
    // get detector for detecting face in given image
    final FaceDetector detector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(mode: FaceDetectorMode.accurate),
    );
    // detect face(s) in image
    faces = await detector.processImage(visionImage).catchError((err) {
      print(err.toString());
      Scaffold.of(context).showSnackBar(_CustomSnackbar(
        message: "Something went wrong",
        context: context,
        function: pickerCamera,
      ));
    });
    detector.close();
    print('No of faces: ${faces.length}');
    // extract face(s)
    if (faces.length < 1) {
      result = null;
      Scaffold.of(context).showSnackBar(_CustomSnackbar(
        message: 'No face detected. Face required',
        context: context,
        function: pickerCamera,
      ));
    } else if (faces.length > 1) {
      result = null;
      Scaffold.of(context).showSnackBar(_CustomSnackbar(
        message: 'More than 1 face detected',
        context: context,
        function: pickerCamera(context, index),
      ));
    } else {
      result = img;
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    firstname = widget.firstname;
    lastname = widget.lastname;
    emailaddress = widget.emailaddress;
    regno = widget.regno;
    programme = widget.programme;
    year = widget.year;
    departments = widget.departments;
    yearsOfStudy = widget.yearsOfStudy;
    programmes = TextDetails(
      "Programme",
      dropdown: true,
      onChanged: _programme,
      items: departments,
      value: programme,
    );
    years = TextDetails(
      "Year of Study",
      dropdown: true,
      onChanged: _year,
      items: yearsOfStudy,
      value: year,
    );
    images = Map();
    msg = "No results available";
    res = Container(
      child: Text(
        msg,
        style: TextStyle(color: Color(0xFF47414d)),
      ),
    );
    isResult = false;
    isLoading = false;
    // A delayed future makes the code in the future run as soon as the currently running code finishes.
    // thus we can query for number of images easily in initState
    Future.delayed(Duration.zero, () => _buildBody(context));
  }

  @override
  void dispose() {
    super.dispose();
    if (images != null) images.clear();
  }

  @override
  Widget build(BuildContext context) {
    _createDirectory;
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
                    msg,
                    style: TextStyle(color: Color(0xFF47414d)),
                  ),
                ),
              )
        : polaroidBody();
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
      body: Container(
        margin: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
        color: Colors.white,
        child: Center(
          child: res,
        ),
      ),
    );
  }

  // Create individual grid items
  Widget _buildGridItems(BuildContext context, int indexOfItem) {
    return GestureDetector(
      child: Card(
        elevation: 5.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(const Radius.circular(10.0)),
          ),
          // set picture only if picture has been taken
          child: images.containsKey('$indexOfItem') &&
                  images['$indexOfItem'] != null
              ? Image.file(images['$indexOfItem'])
              : Icon(
                  Icons.person,
                  color: Colors.grey,
                ),
        ),
      ),
      onTap: () => pickerCamera(context, indexOfItem),
    );
  }

  // Enable reviewing of registration details
  Widget _reviewDetails(BuildContext context) {
    return GestureDetector(
      child: Text(
        'Review details',
        style: TextStyle(
          decoration: TextDecoration.underline,
          color: Color(0xFF428BCA),
          decorationColor: Colors.blue,
        ),
      ),
      onTap: () {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      'DONE',
                      style: TextStyle(
                        color: Colors.green[900],
                        fontSize: 17.5,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
                title: Text(
                  'Review details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextDetails(
                        "Registration Number",
                        value: regno,
                        keyboard: TextInputType.url,
                        onChanged: _regno,
                      ),
                      Padding(padding: EdgeInsets.all(10.0)),
                      TextDetails(
                        "First Name",
                        value: firstname,
                        onChanged: _firstname,
                      ),
                      Padding(padding: EdgeInsets.all(10.0)),
                      TextDetails(
                        "Last Name",
                        value: lastname,
                        onChanged: _lastname,
                      ),
                      Padding(padding: EdgeInsets.all(10.0)),
                      TextDetails(
                        "Email",
                        value: emailaddress,
                        keyboard: TextInputType.emailAddress,
                        onChanged: _email,
                      ),
                      Padding(padding: EdgeInsets.all(10.0)),
                      years,
                      Padding(padding: EdgeInsets.all(10.0)),
                      programmes,
                    ],
                  ),
                ),
              );
            });
      },
    );
  }
}
