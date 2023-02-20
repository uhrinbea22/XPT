import 'package:app/screens/home/diagram.dart';
import 'package:app/screens/home/list.dart';
import 'package:app/screens/home/list_all_transactions.dart';
import 'package:app/screens/home/list_of_categ.dart';
import 'package:app/screens/home/listtry.dart';
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
                'Side menu',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(100, 100, 100, 100),
                //image: DecorationImage(
                //  fit: BoxFit.fill,
                //image: AssetImage('assets/images/cover.jpg'))),
              )),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('Welcome'),
            onTap: () => {},
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Profile'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.border_color),
            title: Text('Transactions'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ListAllTrans()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () async => {await _authService.signOut()},
            // TODO : logout here
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('List try'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListAllCat()),
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
        ],
      ),
    );
  }
}
