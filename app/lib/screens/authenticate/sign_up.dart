import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class SignUp extends StatefulWidget {
  final Function toggleView;
  SignUp({required this.toggleView});
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // text field state
  String email = '';
  String password = '';
  String error = '';
  bool absorbValue = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        elevation: 0.0,
        title: const Text('Sign up to XPT'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20.0),
              TextFormField(
                validator: (value) => value!.isEmpty ? 'Enter an email' : null,
                onChanged: (value) {
                  setState(() => email = value);
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                validator: (value) =>
                    value!.length < 6 ? 'Enter a password 6+ chars long' : null,
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
                      'Sign up',
                      style: TextStyle(color: Color.fromARGB(255, 17, 19, 20)),
                    ),
                    onPressed: () async {
                      setState(() {
                        absorbValue = true;
                      });

                      if (_formKey.currentState!.validate()) {
                        setState(() => loading = true);
                        dynamic result =
                            await _authService.signUp(email, password);
                        if (result != null) {
                          setState(() {
                            error = "Unsuccessful registration";
                            absorbValue = false;
                            loading = false;
                          });
                        }
                      }
                    }),
              ),
              const SizedBox(height: 12.0),
              Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 14.0),
              ),
              TextButton.icon(
                  onPressed: () {
                    widget.toggleView();
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('Sign In'))
            ],
          ),
        ),
      ),
    );
  }
}
