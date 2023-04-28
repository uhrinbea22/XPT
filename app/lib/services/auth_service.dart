import 'package:app/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<UserModel?> get onAuthStateChanged {
    return _auth.authStateChanges().map(_userModelFromFirebase);
  }

  User? getuser() {
    return _auth.currentUser;
  }

  UserModel? _userModelFromFirebase(User? user) {
    if (user != null) {
      return UserModel(uid: user.uid);
    } else {
      return null;
    }
  }

  Future signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user!;
      // send welcome message
      FirebaseFirestore.instance.collection('mail').add({
        'to': email,
        'message': {
          'subject': 'Üdv!',
          'text':
              'Üdv köztünk, a PénZen applikáció használói közt. Kövesd nyomon tranzakcióidat, és légy tudatosabb. Bármi kérdésed van, keress meg minket a pénzen@gmail.com email címen!',
        },
      });
      return _userModelFromFirebase(user);
    } catch (e) {
      return e.toString();
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }

  Future signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user!;
      return _userModelFromFirebase(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<bool> resetPassword({required String email}) async {
    // TODO : check if email has been registered already

    bool _status = false;
    await _auth
        .sendPasswordResetEmail(email: email)
        .then((value) => _status = true)
        .catchError((e) => _status = false);
    return _status;
  }
}
