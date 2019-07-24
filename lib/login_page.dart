import 'dart:io';

import 'package:flutter/material.dart';
import 'package:expensetracker/common/user_sharedpreference.dart';

class LoginPage extends StatefulWidget {

    @override
    LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {

    final _loginFormKey = GlobalKey<FormState>();

    String _userName;
    String _password;
    bool _isFormValid = true;

    @override
    Widget build(BuildContext context) {
        return WillPopScope(child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
            Image(
              image: AssetImage("assets/bg.jpg"),
              fit: BoxFit.cover,
              color: Colors.black87,
              colorBlendMode: BlendMode.darken,
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                 Form(
                   key: _loginFormKey,
                   child: Theme(
                   data: ThemeData(
                     brightness: Brightness.dark,
                     primarySwatch: Colors.teal,
                     inputDecorationTheme: InputDecorationTheme(
                       labelStyle: TextStyle(
                         color: Colors.teal, fontSize: 15.0
                         ),
                     )
                   ),
                   child: Container(
                     padding: const EdgeInsets.all(40.0),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: <Widget>[
                         Text(!_isFormValid ? "Please enter the valid username and password" : "", style: TextStyle(color: Colors.red),),
                         TextFormField(
                           validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter the Email';
                              }
                           },
                           decoration: InputDecoration(
                             labelText: "Enter User Name"
                           ),
                           keyboardType: TextInputType.emailAddress,
                           onSaved: (String value) {
                              setState(() {
                                _userName = value;
                              });
                           },
                         ),
                         TextFormField(
                           validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter the Password';
                              }
                           },
                           decoration: InputDecoration(
                             labelText: "Enter Password"
                           ),
                           keyboardType: TextInputType.text,
                           obscureText: true,
                           onSaved: (String value) {
                              setState(() {
                                _password = value;
                              });
                           },
                         ),
                         Padding(padding: EdgeInsets.only(top: 20.0),),
                         MaterialButton(
                           color: Colors.teal,
                           textColor: Colors.white,
                           child: Text("Login"),
                           onPressed: ()  {
                              login();
                           },
                         )
                       ],
                     ),
                   ),
                 ),) 
              ],)
          ],),
        ),
        onWillPop: () {
          print("ok");
          exit(0);
          return Future(() => false);
        },
        );
    }

    

    void login() {
      final form = _loginFormKey.currentState;
      if (form.validate()) {
        form.save();
        // Call the Service here to authenticate user 
        if(_userName.toUpperCase() == "USERNAME" && _password.toUpperCase() == "PASSWORD") {
           setState(() {
            _isFormValid = true; 
           });
          setUserSharedPreference(_userName);
          Navigator.of(context).pushNamedAndRemoveUntil("/", (Route<dynamic> route) => false);
        }
        else {
           setState(() {
            _isFormValid = false; 
           });
        }
      }
    }
}