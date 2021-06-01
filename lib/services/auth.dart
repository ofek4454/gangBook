import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gangbook/models/auth_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<AuthModel> get userAuth {
    return _auth.authStateChanges.call().map(
          (user) => user == null ? null : AuthModel.fromFirebaseUser(user),
        );
  }

  Future<bool> signUpUser({String email, String password, String name}) async {
    bool retVal = false;
    try {
      final UserCredential _credentials = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (_credentials != null) {
        final result = await createUser(
            uid: _credentials.user.uid, email: email, name: name);
        if (result == 'success') {
          retVal = true;
        }
      }
    } catch (e) {
      print(e);
      throw e;
    }
    return retVal;
  }

  Future<bool> logInUser({String email, String password}) async {
    bool retVal = false;
    try {
      final UserCredential _credentials = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      if (_credentials != null) {
        retVal = true;
      }
    } catch (e) {
      print(e);
      throw e;
    }
    return retVal;
  }

  Future<bool> logInWithGoogle() async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );
    try {
      GoogleSignInAccount _googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication _googleAuth = await _googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: _googleAuth.idToken, accessToken: _googleAuth.accessToken);
      UserCredential _userCresential =
          await _auth.signInWithCredential(credential);

      if (_userCresential.additionalUserInfo.isNewUser) {
        createUser(
          uid: _userCresential.user.uid,
          email: _userCresential.user.email,
          name: _userCresential.user.displayName,
        );
      }
      if (_userCresential != null) {
        return true;
      }
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<String> signOut() async {
    String retVal = 'error';

    try {
      await _auth.signOut();
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> createUser({String uid, String name, String email}) async {
    String retVal = 'error';
    final _firestore = FirebaseFirestore.instance;
    try {
      await _firestore.collection('users').doc(uid).set({
        'fullname': name,
        'email': email,
        'createdAt': Timestamp.now(),
      });
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }
}
