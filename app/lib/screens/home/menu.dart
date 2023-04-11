import 'package:app/screens/home/calendar.dart';
import 'package:app/screens/home/create_transaction.dart';
import 'package:app/screens/home/fileupload.dart';
import 'package:app/screens/home/flutter_diagram.dart';
import 'package:app/screens/home/list_all_transactions.dart';
import 'package:app/screens/home/list_of_categ.dart';
import 'package:app/screens/home/map.dart';
import 'package:app/screens/home/profile.dart';
import 'package:app/screens/home/remnder.dart';
import 'package:app/screens/home/settings.dart';
import 'package:app/screens/wrapper.dart';
import 'package:app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'category_limits.dart';

class NavDrawer extends StatelessWidget {
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.black, fontSize: 25),
              ),
              decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                      image:
                          const AssetImage("../../assets/images/xpt_logo.png"),
                      fit: BoxFit.cover))),
          ExpansionTile(
            leading: Icon(Icons.border_color),
            title: Text('Transactions'),
            children: [
              ListTile(
                title: Text("List transactions"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ListAllTrans()),
                  );
                },
              ),
              ListTile(
                title: Text("Add new"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateTransacton()),
                  );
                },
              ),
            ],
          ),
          ListTile(
            leading: Icon(Icons.verified_user_sharp),
            title: Text('Profile'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () async => {
              await _authService.signOut(),
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Wrapper()),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.dangerous_outlined),
            title: Text('Pic '),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImageUploads()),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_month),
            title: Text('Calendar'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Calendar()),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_month),
            title: Text('Limits'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoryLimits()),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_month),
            title: Text('Diagrams'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RealtimeDiagram()),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.note_add_sharp),
            title: Text('Reminders'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RealtimeDiagram()),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.note_add_sharp),
            title: Text('Map'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyApp3()),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.note_add_sharp),
            title: Text('M,FA'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyApp2()),
              ),
            },
          ),
        ],
      ),
    );
  }
}
