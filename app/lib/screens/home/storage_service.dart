import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Storage {
  final FirebaseStorage storage = FirebaseStorage.instance;


  Future<String?> downloadUrl() async {
       var downloadURL = await FirebaseStorage.instance
        .ref()
        .child("file/Gabinak3.png")
        .getDownloadURL();
    print(downloadURL);
    return downloadURL;

  }
}
