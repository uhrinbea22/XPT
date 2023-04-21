import 'package:app/screens/home/menu.dart';
import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(SettingsScreen());
}

class AppThemes {
  static const int LightBlue = 0;
  static const int LightRed = 1;
  static const int DarkBlue = 2;
  static const int DarkRed = 3;

  static String toStr(int themeId) {
    switch (themeId) {
      case LightBlue:
        return "Világos kék";
      case LightRed:
        return "Világos piros";
      case DarkBlue:
        return "Sötét kék";
      case DarkRed:
        return "Sötét piros";
      default:
        return "Válassz";
    }
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dark = ThemeData.dark();
    final darkButtonTheme =
        dark.buttonTheme.copyWith(buttonColor: Colors.grey[700]);
    final darkFABTheme = dark.floatingActionButtonTheme;

    final themeCollection = ThemeCollection(themes: {
      AppThemes.LightBlue: ThemeData(primarySwatch: Colors.blue),
      AppThemes.LightRed: ThemeData(primarySwatch: Colors.red),
      AppThemes.DarkBlue: dark.copyWith(
          accentColor: Colors.blue,
          buttonTheme: darkButtonTheme,
          floatingActionButtonTheme:
              darkFABTheme.copyWith(backgroundColor: Colors.blue)),
      AppThemes.DarkRed: ThemeData.from(
          colorScheme:
              ColorScheme.dark(primary: Colors.red, secondary: Colors.red)),
    });

    return DynamicTheme(
        themeCollection: themeCollection,
        defaultThemeId: AppThemes.LightBlue,
        builder: (context, theme) {
          return MaterialApp(
            title: 'Beállítások',
            theme: theme,
            home: HomePage(title: 'Beállítások'),
          );
        });
  }
}

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({Key? key, required this.title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int dropdownValue = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    dropdownValue = DynamicTheme.of(context)!.themeId;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: NavDrawer(),
      body: Center(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 12),
            child: Text('Válaszd ki a preferált témát:'),
          ),
          DropdownButton(
              icon: Icon(Icons.arrow_downward),
              value: dropdownValue,
              items: [
                DropdownMenuItem(
                  value: AppThemes.LightBlue,
                  child: Text(AppThemes.toStr(AppThemes.LightBlue)),
                ),
                DropdownMenuItem(
                  value: AppThemes.LightRed,
                  child: Text(AppThemes.toStr(AppThemes.LightRed)),
                ),
                DropdownMenuItem(
                  value: AppThemes.DarkBlue,
                  child: Text(AppThemes.toStr(AppThemes.DarkBlue)),
                ),
                DropdownMenuItem(
                  value: AppThemes.DarkRed,
                  child: Text(AppThemes.toStr(AppThemes.DarkRed)),
                )
              ],
              onChanged: (dynamic themeId) async {
                await DynamicTheme.of(context)!.setTheme(themeId);
                setState(() {
                  dropdownValue = themeId;
                });
              }),
        ],
      )),
    );
  }
}
