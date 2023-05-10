import 'package:firebase_storage/firebase_storage.dart';

class Storage {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String?> downloadUrl(String userId, String transactionId) async {
    var downloadURL = await FirebaseStorage.instance
        .ref()
        .child(userId)
        .child(transactionId)
        .getDownloadURL();
    return downloadURL;
  }
}
