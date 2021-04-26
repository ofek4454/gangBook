import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gangbook/models/app_user.dart';
import 'package:gangbook/services/database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CurrentUser extends ChangeNotifier {
  AppUser _appUser = AppUser();

  FirebaseAuth _auth = FirebaseAuth.instance;

  AppUser get user => _appUser;

  Future<String> tryAutoLogIn() async {
    String retVal = 'error';

    try {
      final _user = _auth.currentUser;
      _appUser = await AppDB().getUserInfoByUid(_user.uid);
      if (_appUser != null) {
        retVal = 'success';
      }
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<bool> signUpUser({String email, String password, String name}) async {
    bool retVal = false;
    try {
      final UserCredential _credentials = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (_credentials != null) {
        _appUser.uid = _credentials.user.uid;
        _appUser.email = email;
        _appUser.fullName = name;
        _appUser.createdAt = Timestamp.now();
        final result = await AppDB().createUser(_appUser);
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
        _appUser = await AppDB().getUserInfoByUid(_credentials.user.uid);
        if (_appUser != null) {
          retVal = true;
        }
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
      _appUser.uid = _userCresential.user.uid;
      _appUser.email = _userCresential.user.email;
      if (_userCresential.additionalUserInfo.isNewUser) {
        _appUser.fullName = _userCresential.user.displayName;
        _appUser.createdAt = Timestamp.now();
        AppDB().createUser(_appUser);
      } else {
        _appUser = await AppDB().getUserInfoByUid(_userCresential.user.uid);
        if (_appUser == null) {
          return false;
        }
      }
      return true;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<String> signOut() async {
    String retVal = 'error';

    try {
      await _auth.signOut();
      _appUser = AppUser();
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }
}
