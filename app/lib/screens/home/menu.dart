import 'package:app/screens/home/calendar.dart';
import 'package:app/screens/home/notification.dart';
import 'package:app/screens/home/transactions/create_transaction.dart';
import 'package:app/screens/home/transactions/fileupload.dart';
import 'package:app/screens/home/flutter_diagram.dart';
import 'package:app/screens/home/transactions/list_all_transactions.dart';
import 'package:app/screens/home/map.dart';
import 'package:app/screens/home/profile.dart';
import 'package:app/screens/home/reminder.dart';
import 'package:app/screens/home/settings.dart';
import 'package:app/screens/wrapper.dart';
import 'package:app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/home/categories/list_category_limits.dart';

class NavDrawer extends StatelessWidget {
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.black, fontSize: 25),
              )),
          ExpansionTile(
            leading: const Icon(Icons.border_color),
            title: const Text('Transactions'),
            children: [
              ListTile(
                title: const Text("List transactions"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ListAllTrans()),
                  );
                },
              ),
              ListTile(
                title: const Text("Add new"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateTransaction()),
                  );
                },
              ),
            ],
          ),

          // TODO : move it to createTransaction
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('THEME '),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DynamicThemesExampleApp()),
              ),
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Calendar'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Calendar()),
              ),
            },
          ),
          ListTile(
            leading: const Icon(Icons.maximize),
            title: const Text('Limits'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryLimits()),
              ),
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Diagrams'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DiagramScreen()),
              ),
            },
          ),
          ListTile(
            leading: const Icon(Icons.note_add_sharp),
            title: const Text('Map'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapWidget()),
              ),
            },
          ),
          ListTile(
            leading: const Icon(Icons.note_add_rounded),
            title: const Text('IMG'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImageUploads()),
              ),
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified_user_sharp),
            title: const Text('Profile'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              ),
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ),
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () async => {
              await _authService.signOut(),
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Wrapper()),
              ),
            },
          ),
        ],
      ),
    );
  }
}
