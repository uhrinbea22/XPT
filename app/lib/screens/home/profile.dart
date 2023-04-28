import 'dart:io';
import 'package:app/screens/home/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../firebase_options.dart';
import '../../services/auth_service.dart';
import 'package:app/firebase_options.dart';
import 'package:app/screens/home/menu.dart';
import 'package:app/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
/* 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProfileStateful());
} */
/* 
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  // const ProfileScreen();
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Profil';
    return MaterialApp(
      title: appTitle,
      theme: Theme.of(context),
      home: Scaffold(
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text(appTitle),
        ),
        body: ProfileStateful(),
      ),
    );
  }
} */

class ProfileStateful extends StatefulWidget {
  final AuthService _authService = AuthService();
  @override
  MyCustomFormStat createState() {
    return MyCustomFormStat();
  }
}

class MyCustomFormStat extends State<ProfileStateful> {
  final String title = "";
  final AuthService _authService = AuthService();
  final displayNameController = TextEditingController();
  String resetPasswordStatus = "";
  String displayName = "";
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  File? _photo;
  final ImagePicker _picker = ImagePicker();
  String imgName = "";

  @override
  void initState() {
    //displayNameController.text = _authService.getuser()!.displayName! ?? "";
    //displayName = _authService.getuser()!.displayName!;
    super.initState();
  }

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    if (_photo == null) return;
    imgName = "profile";
    String directory = _authService.getuser()!.uid;
    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref("$directory/")
          .child("/$imgName");
      await ref.putFile(_photo!);
    } catch (e) {
      print('error occured');
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Galéria'),
                      onTap: () {
                        imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Kamera'),
                    onTap: () {
                      imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        uploadFile();
                      },
                      child: const Text("Kép feltöltése"))
                ],
              ),
            ),
          );
        });
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile();
      } else {
        //TODO : warn user that no image is selected
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Storage storage = Storage();
    User? user = _authService.getuser();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text(title),
        ),
        body: Column(
          children: [
            ListTile(
              title: Text("Profil beállítások"),
            ),
            TextFormField(
              readOnly: true,
              initialValue: user?.email,
              decoration: const InputDecoration(
                  icon: Icon(Icons.email_rounded), labelText: "Email cím"),
            ),
            TextFormField(
              controller: displayNameController,
              decoration: const InputDecoration(
                  icon: Icon(Icons.face_outlined), labelText: "Név"),
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    user!.updateDisplayName(displayNameController.text);
                    displayName = displayNameController.text;
                  });
                },
                child: const Text("Név beállítása")),
            Padding(
                padding: EdgeInsetsDirectional.all(10),
                child: Text("Avatar feltöltése")),
            Center(
                child: GestureDetector(
              onTap: () {
                _showPicker(context);
              },
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Color(0xffFDCF09),
                child: _photo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.file(
                          _photo!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.fitHeight,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(50)),
                        width: 100,
                        height: 100,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey[800],
                        ),
                      ),
              ),
            )),
            ListTile(
              title: Text("Biztonság"),
            ),
            ElevatedButton(
                onPressed: () async {
                  //send reset password email
                  final _status = await _authService.resetPassword(
                      email: user!.email.toString());
                  if (_status) {
                    setState(() {
                      resetPasswordStatus = 'Email elküldve!';
                    });
                  } else {
                    setState(() {
                      resetPasswordStatus = 'Hiba történt!';
                    });
                  }
                },
                child: const Text("Jelszó visszaállítása")),
            Text(resetPasswordStatus)
          ],
        ));
  }
}
