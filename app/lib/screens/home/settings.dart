import 'package:app/screens/home/list_all_transactions.dart';
import 'package:app/screens/home/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../firebase_options.dart';
import '../../models/transact.dart';
import '../../services/auth_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(SettingsScreen());
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Settings';
    return MaterialApp(
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      title: appTitle,
      home: Scaffold(
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text(appTitle),
          backgroundColor: Colors.grey,
        ),
        body: Settings(),
      ),
    );
  }
}

// Create a Form widget.
class Settings extends StatefulWidget {
  var _streamCategoriesList;
  @override
  SettingState createState() {
    return SettingState();
  }
}

// Create a corresponding State class. This class holds data related to the form.
class SettingState extends State<Settings> {
  String dropdownvalue = 'Food';

  @override
  void initState() {
    super.initState();
  }

  //var valuefirst;
  bool night_mode_on = false;

  var night_mode_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    User? user = _authService.getuser();
    return Scaffold(
        body: Column(children: [
      Text(user!.email.toString()),
      Container(
        child: CheckboxListTile(
          title: Text('Night mode'),
          checkColor: Colors.grey,
          activeColor: Colors.blue,
          value: night_mode_on,
          onChanged: (bool? value) {
            setState(() {
              night_mode_on = !night_mode_on;
            });
          },
        ),
      )
    ]));
  }
}
