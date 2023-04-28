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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
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
                            return Row(
                              children: <Widget>[
                                Container(
                                    height: 60,
                                    width: 60,
                                    child: CircleAvatar(
                                      //ide az assets-ből user_avatar.png-fajlt
                                      child: Image.asset(
                                        'user_avatar.png',
                                        width: 300,
                                        height: 300,
                                      ),
                                    )),
                              ],
                            );
                          }
                          if (snapshot.hasError) return Text('Hiba történt');

                          return Row(
                            children: <Widget>[
                              Container(
                                  height: 60,
                                  width: 60,
                                  child: CircleAvatar(
                                      radius: 35,
                                      backgroundColor: Colors.transparent,
                                      child: ClipOval(
                                        child: Image.network(
                                          snapshot.data!,
                                          fit: BoxFit.fill,
                                          width: 300,
                                          height: 300,
                                        ),
                                      ))),
                            ],
                          );
                        }),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _authService.getuser()!.displayName == null
                              ? _authService.getuser()!.email.toString()
                              : _authService.getuser()!.displayName.toString(),
                          style: TextStyle(fontSize: 20),
                        ),
                      )
                    ],
                  )
                ]),
          ),
          ExpansionTile(
            leading: const Icon(Icons.border_color),
            title: const Text('Tranzakciók'),
            children: [
              ListTile(
                title: const Text("Tranzakciók listázása"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ListAllTransactions()),
                  );
                },
              ),
              ListTile(
                title: const Text('Kategóriára szűrés'),
                onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TransactionsByCategoryPage()),
                  ),
                },
              ),
              ListTile(
                title: const Text("Új hozzáadása"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateTransactionPage()),
                  );
                },
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Naptár'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Calendar()),
              ),
            },
          ),
          ListTile(
            leading: const Icon(Icons.maximize),
            title: const Text('Limitek'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryLimits()),
              ),
            },
          ),
          ListTile(
            leading: const Icon(Icons.line_style_rounded),
            title: const Text('Diagramok'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DiagramScreen()),
              ),
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified_user_sharp),
            title: const Text('Profil'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileStateful()),
              ),
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Beállítások'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              ),
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Kijelentkezés'),
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
