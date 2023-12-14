import 'dart:io';
import 'package:app/services/auth_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();
  final AuthService _authService = AuthService();
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future imgFromGalleryProfile() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      var pic = File(pickedFile.path);
      uploadProfilePicture(pic);
    } else {
      return null;
    }
  }

  Future imgFromCameraProfile() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      var pic = File(pickedFile.path);
      uploadProfilePicture(pic);
    } else {
      return null;
    }
  }

  Future uploadProfilePicture(File photo) async {
    if (photo == null) return;
    String imgName = "profile";
    String directory = _authService.getuser()!.uid;
    try {
      final ref = storage.ref("$directory/").child("/$imgName");
      await ref.putFile(photo);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      var pic = File(pickedFile.path);
      uploadPicture(pic);
      return pickedFile.path;
    } else {
      return null;
    }
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      var pic = File(pickedFile.path);
      uploadPicture(pic);
      return pickedFile.path;
    } else {
      return null;
    }
  }

  Future uploadPicture(File photo) async {
    if (photo == null) return;
    String imgName = basename(photo.path);
    String directory = _authService.getuser()!.uid;
    try {
      final ref = storage.ref("$directory/").child("/$imgName");
      await ref.putFile(photo);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  void showPickerProfile(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('Galéria'),
                      onTap: () async {
                        await imgFromGalleryProfile();
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: Text('Kamera'),
                    onTap: () async {
                      await imgFromCameraProfile();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('Galéria'),
                      onTap: () async {
                        await imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Kamera'),
                    onTap: () async {
                      await imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
