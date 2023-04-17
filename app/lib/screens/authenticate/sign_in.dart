import 'package:app/services/auth_service.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({required this.toggleView});
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  String error = '';
  String email = '';
  String password = '';
  String resetPasswordStatus = '';
  bool absorbValue = false;

  bool _isPressed = false;

  // This function is called when the button gets pressed
  void _myCallback() {
    setState(() {
      _isPressed = true;
    });
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
                  widget.toggleView();
                },
                style: TextButton.styleFrom(
                  primary: const Color.fromARGB(255, 25, 28, 29),
                ),
                icon: const Icon(Icons.person),
                label: const Text('Sign Up'))
          ],
        ),
        body: Column(children: [
          Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                  child: Column(
                children: <Widget>[
                  const SizedBox(height: 20.0),
                  TextFormField(
                    validator: (value) =>
                        value!.isEmpty ? 'Enter an email' : null,
                    onChanged: (value) {
                      setState(() => email = value);
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    validator: (value) => value!.length < 6
                        ? 'Enter a password 6+ chars long'
                        : null,
                    obscureText: true,
                    onChanged: (value) {
                      setState(() => password = value);
                    },
                  ),
                  const SizedBox(height: 20.0),
                  AbsorbPointer(
                    absorbing: absorbValue,
                    child: ElevatedButton(
                      child: const Text(
                        'Sign in',
                      ),
                      onPressed: () async {
                        setState(() {
                          absorbValue = true;
                        });

                        dynamic result =
                            await _authService.signIn(email, password);
                        if (result == null) {
                          setState(() {
                            error = 'Could not sign in with the credentials';
                            absorbValue = false;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    error,
                    style: const TextStyle(color: Colors.red, fontSize: 14.0),
                  ),
                ],
              ))),
          IgnorePointer(
            ignoring: true,
            child: ElevatedButton(
                onPressed: () async {
                  final _status =
                      await _authService.resetPassword(email: email.toString());
                  if (_status) {
                    setState(() {
                      resetPasswordStatus = 'Email sent';
                    });
                  } else {
                    setState(() {
                      resetPasswordStatus = 'Error happened!';
                    });
                  }
                },
                child: const Text("Reset pasword")),
          ),
          Text(
            resetPasswordStatus,
            style: const TextStyle(color: Colors.red, fontSize: 14.0),
          ),
        ]));
  }
}
