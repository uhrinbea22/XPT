import 'package:app/screens/home/menu.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(SettingsScreen());
}

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
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.green),

      // standard dark theme
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text('Device Controlled theme Mode'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose your theme:',
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Change theme & rebuild to
                  // show it using these buttons
                  ElevatedButton(
                      onPressed: () {
                        changeTheme(ThemeMode.light);
                      },
                      child: Text('Light theme')),
                  ElevatedButton(
                      onPressed: () {
                        changeTheme(ThemeMode.dark);
                      },
                      child: Text('Dark theme')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
