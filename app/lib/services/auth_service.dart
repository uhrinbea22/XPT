import 'package:app/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // auth change user stream
  Stream<UserModel?> get onAuthStateChanged {
    return _auth
        .authStateChanges()
        //.map((User? user) => _userModelFromFirebase(user));
        .map(_userModelFromFirebase);
  }

  User? getuser() {
    return _auth.currentUser;
  }

  //create an userModel object based on Firebase User object
  UserModel? _userModelFromFirebase(User? user) {
    if (user != null) {
      return UserModel(uid: user.uid);
    } else {
      return null;
    }
  }

  //sing in with email & password
  Future signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

//sign up with email & password
  Future signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user!;
      FirebaseFirestore.instance.collection('mail').add({
        'to': email,
        'message': {
          'subject': 'Hello from XPT!',
          'text':
              'Welcome in XPT Community, where we keep a budget and follow our transactions here. If you have any questions about the app, please let us know at xpt_expense_tracker_app@gmail.com',
        },
      });
      return _userModelFromFirebase(user);
    } catch (e) {
      return e.toString();
    }
  }

//sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }

//sign in anonymously, it's an asynchronous task, it's going to return a future
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
