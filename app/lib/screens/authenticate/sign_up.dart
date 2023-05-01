import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

//Sign up screen
class SignUp extends StatefulWidget {
  final Function toggleView;
  SignUp({required this.toggleView});
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';
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
        title: const Text('Regisztrálj a PénZen-re!'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Írd be az email címed";
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
                    ? 'A jelszó túl rövid! Min. 6 karakter hosszú legyen.'
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
              const SizedBox(height: 20.0),
              AbsorbPointer(
                absorbing: absorbValue,
                child: ElevatedButton(
                  child: const Text(
                    'Regisztáció',
                  ),
                  onPressed: () async {
                    setState(() {
                      absorbValue = true;
                    });
                    if (_formKey.currentState!.validate()) {
                      dynamic result =
                          await _authService.signUp(email, password);
                      if (result != null) {
                        setState(() {
                          error = "Sikertelen regisztráció";
                          absorbValue = false;
                        });
                      }
                    } else {
                      setState(() {
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
                ),
              ),
              const SizedBox(height: 5.0),
              Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 14.0),
              ),
              const SizedBox(height: 10.0),
              const Text(
                "Már van fiókod?",
                style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 10,
                    fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 5.0),
              TextButton(
                  onPressed: () {
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
                  child: const Text('Bejelentkezés'))
            ],
          ),
        ),
      ),
    );
  }
}
