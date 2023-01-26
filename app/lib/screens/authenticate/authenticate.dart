import 'dart:html';
import 'dart:js';

import 'package:app/screens/authenticate/sign_in.dart';
import 'package:app/screens/authenticate/sign_up.dart';
import 'package:app/screens/home/firestore_test.dart';
import 'package:app/screens/home/create_transaction.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;
  void toggelView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      //return SignIn(toggelView: toggelView);
      //return CreateTransacton();
      return App();
    } else {
      return SignUp(toggelView: toggelView);
    }
  }
}
