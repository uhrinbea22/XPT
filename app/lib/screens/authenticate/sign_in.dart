import 'dart:ui';
import 'package:app/services/auth_service.dart';
import 'package:flutter/material.dart';

///Sign in screen
class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({required this.toggleView});
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  ///Declare important variables
  String error = '';
  String email = '';
  String password = '';
  String resetPasswordStatus = '';
  bool absorbValue = false;
  bool _passVisibility = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          elevation: 0.0,
          title: const Text('Bejelentkezés'),
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
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                    labelText: "Email cím",
                    floatingLabelStyle: const TextStyle(
                        height: 1, color: Color.fromARGB(255, 160, 26, 179)),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),

                  ///validate the user data
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Írd be az email címed!";
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return "Helytelen formátum!";
                    }
                  },
                  onChanged: (value) {
                    setState(() => email = value);
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => value!.length < 6
                      ? 'A jelszú túl rövid! (min 6 karakter)'
                      : null,
                  obscureText: _passVisibility,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                    labelText: "Jelszó",
                    floatingLabelStyle: const TextStyle(
                        height: 1, color: Color.fromARGB(255, 160, 26, 179)),
                    filled: true,
                    fillColor: Colors.grey[200],
                    suffixIcon: IconButton(
                      icon: _passVisibility
                          ? const Icon(Icons.visibility_off)
                          : const Icon(Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _passVisibility = !_passVisibility;
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => password = value);
                  },
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: AbsorbPointer(
                    absorbing: absorbValue,
                    child: TextButton(
                        onPressed: () async {
                          final _status = await _authService.resetPassword(
                              email: email.toString());
                          if (_status) {
                            setState(() {
                              resetPasswordStatus =
                                  'Email elküldve! Ellenőrizd postaládád!';
                            });
                          } else {
                            setState(() {
                              resetPasswordStatus = 'Hiba történt!';
                            });
                          }
                        },
                        child: const Text(
                          "Elfelejtetted jeszavad?",
                          style: TextStyle(
                              fontSize: 10.0, fontStyle: FontStyle.italic),
                        )),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    resetPasswordStatus,
                    style: const TextStyle(
                        color: Colors.purpleAccent, fontSize: 10.0),
                  ),
                ),
                const SizedBox(height: 10.0),
                AbsorbPointer(
                  absorbing: absorbValue,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        absorbValue = true;
                      });

                      ///sign in the user using Firebase AuthService
                      dynamic result =
                          await _authService.signIn(email, password);
                      if (result == null) {
                        setState(() {
                          error = 'Sikertelen bejelentkezés!';
                          absorbValue = false;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blueAccent,
                      onPrimary: Colors.white,
                      onSurface: Colors.grey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 10.0,
                    ),
                    child: const Text('Bejelentkezés'),
                  ),
                ),
              ],
            )),
          ),
          const SizedBox(height: 2.0),
          Text(
            error,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12.0,
            ),
          ),
          const Text(
            "Még nincs fiókod?",
            style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 10,
                fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 5.0),
          TextButton(
              onPressed: () {
                ///navigate to registration page if user has no account yet
                widget.toggleView();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent,
                onPrimary: Colors.white,
                onSurface: Colors.grey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 10.0,
              ),
              child: const Text('Regisztráció'))
        ]));
  }
}
