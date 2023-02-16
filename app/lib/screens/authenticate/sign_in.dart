import 'package:app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  final Function toggelView;
  SignIn({required this.toggelView});
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    _loadUserEmailPassword();
    super.initState();
  }

  // text field state
  String error = '';
  late String email;
  late String password;
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.lightBlue,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 41, 39, 39),
          elevation: 0.0,
          title: const Text('Sign in to XPT'),
          actions: <Widget>[
            TextButton.icon(
                onPressed: () {
                  widget.toggelView();
                },
                style: TextButton.styleFrom(
                  primary: const Color.fromARGB(255, 25, 28, 29),
                ),
                icon: const Icon(Icons.person),
                label: const Text('Sign Up'))
          ],
        ),
        body: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: Form(
                child: Column(
              children: <Widget>[
                const SizedBox(height: 20.0),
                TextFormField(
                  validator: (value) =>
                      value!.isEmpty ? 'Enter an email' : null,
                  initialValue: email,
                  onChanged: (value) {
                    setState(() => email = value);
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  validator: (value) => value!.length < 6
                      ? 'Enter a password 6+ charts long'
                      : null,
                  obscureText: true,
                  initialValue: password,
                  onChanged: (value) {
                    print(value);
                    setState(() => password = value);
                  },
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                    child: const Text(
                      'Sign in',
                      style:
                          TextStyle(color: Color.fromARGB(255, 132, 132, 132)),
                    ),
                    onPressed: () async {
                      //TODO: VALIDATE
                      //if (_formKey.currentState!.validate()) {
                      dynamic result =
                          await _authService.signIn(email, password);
                      if (result == null) {
                        setState(() {
                          error = 'Could not sign in with the credentials';
                          print(error);
                        });
                      }
                      // }
                    }),
                Checkbox(
                    activeColor: Color(0xff00C8E8),
                    value: _isChecked,
                    onChanged: _handleRemeberme),
                const SizedBox(height: 12.0),
                Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 14.0),
                )
              ],
            ))));
  }

  void _handleRemeberme(bool? value) {
    _isChecked = value!;
    print(email);
    print(password);
    SharedPreferences.getInstance().then(
      (prefs) {
        prefs.setBool("remember_me", value);
        prefs.setString('email', email);
        prefs.setString('password', password);
      },
    );
    setState(() {
      _isChecked = value;
    });
  }

  void _loadUserEmailPassword() async {
    try {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      var _email = _prefs.getString("email") ?? "";
      var _password = _prefs.getString("password") ?? "";
      var _remeberMe = _prefs.getBool("remember_me") ?? false;
      print(_remeberMe);
      print(_email);
      print(_password);
      if (_remeberMe) {
        setState(() {
          _isChecked = true;
        });
        email = _email ?? "";
        password = _password ?? "";
        print(email);
        print(password);
      }
      print(email);
      print(password);
    } catch (e) {
      print(e);
    }
  }
}
