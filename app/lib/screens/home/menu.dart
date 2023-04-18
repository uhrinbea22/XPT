import 'package:app/screens/home/calendar.dart';
import 'package:app/screens/home/settings.dart';
import 'package:app/screens/home/transactions/category_list.dart';
import 'package:app/screens/home/transactions/create_transaction.dart';
import 'package:app/screens/home/diagram.dart';
import 'package:app/screens/home/transactions/list_all_transactions.dart';
import 'package:app/screens/home/profile.dart';
import 'package:app/screens/wrapper.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/home/categories/list_category_limits.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NavDrawer extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    Storage storage = Storage();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Offstage(
                    offstage: false,
                    child: FutureBuilder(
                        future: storage.downloadUrl(
                            _authService.getuser()!.uid, "profile"),
                        builder: (BuildContext context,
                            AsyncSnapshot<String?> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return LoadingAnimationWidget.staggeredDotsWave(
                              color: Colors.blue,
                              size: 20,
                            );
                          }

                          if (!snapshot.hasData) {
                            return CircleAvatar(backgroundColor: Colors.grey);
                          }
                          if (snapshot.hasError)
                            return Text('Something went wrong');
                          return CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.transparent,
                              child: ClipOval(
                                child: Image.network(
                                  snapshot.data!,
                                  fit: BoxFit.fill,
                                  width: 100,
                                  height: 100,
                                ),
                              ));
                        }),
                  ),
                  Text(_authService.getuser()!.displayName.toString()),
                ]),
          ),
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
                title: const Text('List by categories'),
                onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategLiast()),
                  ),
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
            leading: const Icon(Icons.line_style_rounded),
            title: const Text('Diagrams'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DiagramScreen()),
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
                MaterialPageRoute(builder: (context) => SettingsScreen()),
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
