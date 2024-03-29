import 'package:app/models/userModel.dart';
import 'package:app/screens/authenticate/authenticate.dart';
import 'package:app/screens/home/diagram.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel?>(context);
    if (userModel == null) {
      return Authenticate();
    } else {
      return DiagramScreen();
    }
  }
}
