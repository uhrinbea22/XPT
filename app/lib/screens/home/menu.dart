import 'package:app/screens/home/calendar.dart';
import 'package:app/screens/home/create_transaction.dart';
import 'package:app/screens/home/diagram.dart';
import 'package:app/screens/home/fileupload.dart';
import 'package:app/screens/home/list_all_transactions.dart';
import 'package:app/screens/home/profile.dart';
import 'package:app/screens/home/settings.dart';
import 'package:app/screens/wrapper.dart';
import 'package:app/services/auth_service.dart';
import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(100, 100, 100, 100),
              )),
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
            leading: Icon(Icons.verified_user_outlined),
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
            // TODO : logout here
          ),
          ListTile(
            leading: Icon(Icons.dangerous_outlined),
            title: Text('Diagram'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DiagramPage()),
              ),
            },
            // TODO : logout here
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
            // TODO : logout here
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
            // TODO : logout here
          ),
        ],
      ),
    );
  }
}
