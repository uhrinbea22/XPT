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

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // text field state
  String error = '';
  String email = '';
  String password = '';
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _loadUserEmailPassword();
  }

  String getEmailValue() {
    if (email != '') {
      return email;
    } else {
      return '';
    }
  }

  String getPasswordValue() {
    if (password != '') {
      return password;
    } else {
      return '';
    }
  }

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
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20.0),
              TextFormField(
                //controller: emailController,
                validator: (text) => text!.isEmpty ? 'Enter an email' : null,
                initialValue: getEmailValue(),
                onChanged: (text) {
                  print(text);
                  setState(() => email = text);
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                //controller: passwordController,
                validator: (value) => value!.length < 6
                    ? 'Enter a password 6+ charts long'
                    : null,
                obscureText: true,
                initialValue: getPasswordValue(),
                onChanged: (value) {
                  print(value);
                  setState(() => password = value);
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                  child: const Text(
                    'Sign in',
                    style: TextStyle(color: Color.fromARGB(255, 132, 132, 132)),
                  ),
                  onPressed: () async {
                    //TODO: VALIDATE
                    //if (_formKey.currentState!.validate()) {
                    dynamic result = await _authService.signIn(email, password);
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
                  onChanged: _handleRemeberme,
                  hoverColor: Colors.blue),
              Text('Remember me'),
              const SizedBox(height: 12.0),
              Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 14.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRemeberme(bool? value) async {
    _isChecked = value!;

    SharedPreferences.getInstance().then(
      (prefs) {
        prefs.setBool("remember_me", value);
        prefs.setString('email', email);
        prefs.setString('password', password);
        //prefs.setString('email', emailController.text);
        //prefs.setString('password', passwordController.text);
      },
    );
    setState(() {
      _isChecked = value;
    });
  }

  void _loadUserEmailPassword() async {
    try {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      var _email = _prefs.getString('email') ?? "";
      var _password = _prefs.getString('password') ?? "";
      var _remeberMe = _prefs.getBool("remember_me") ?? false;
      print(_remeberMe);
      print(_email);
      print(_password);
      if (_remeberMe) {
        setState(() {
          _isChecked = true;
        });
        email = _email;
        password = _password;
        //emailController.text = _email;
        //passwordController.text = _password;
      }
    } catch (e) {
      print(e);
    }
  }
}
