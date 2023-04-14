import 'package:app/screens/home/menu.dart';
import 'package:app/screens/home/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(SettingsScreen());
}

// TODO : implement this for the whole app
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _RunMyAppState();
}

class _RunMyAppState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.system;
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    SharedPreferences prefs;
    return Consumer<ThemeNotifier>(
      builder: (context, theme, _) => MaterialApp(
        theme: theme.getTheme(),
        home: Scaffold(
          drawer: NavDrawer(),
          appBar: AppBar(
            title: Text('Hybrid Theme'),
          ),
          body: Row(
            children: [
              Container(
                child: FlatButton(
                  onPressed: () async => {
                    print('Set Light Theme'),
                    theme.setLightMode(),
                    prefs = await SharedPreferences.getInstance(),
                    prefs.setString('theme', "light")
                  },
                  child: Text('Set Light Theme'),
                ),
              ),
              Container(
                child: FlatButton(
                  onPressed: () async => {
                    print('Set Dark theme'),
                    theme.setDarkMode(),
                    prefs = await SharedPreferences.getInstance(),
                    prefs.setString('theme', "dark")
                  },
                  child: Text('Set Dark theme'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
