import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Storage {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String?> downloadUrl(String userid, String transactionId) async {
    var downloadURL = await FirebaseStorage.instance
        .ref()
        .child("$userid")
        .child("$transactionId")
        .getDownloadURL();
    print(downloadURL);
    return downloadURL;
  }
}
