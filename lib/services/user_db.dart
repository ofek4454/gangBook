import 'package:cloud_firestore/cloud_firestore.dart';

class UserDB {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, String>> getUserName(String uid) async {
    Map<String, String> retVal = {};
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();

      retVal['name'] = userDoc.data()['fullname'];
      retVal['imageUrl'] = userDoc.data()['profileImageUrl'];
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> updateProfileImage(String userId, String imageUrl) async {
    String retVal = 'error';
    try {
      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': imageUrl,
      });
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> savePost(String userId, String postId) async {
    String retVal = 'error';
    try {
      await _firestore.collection('users').doc(userId).update({
        'savedPosts': FieldValue.arrayUnion([postId])
      });
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> unSavePost(String userId, String postId) async {
    String retVal = 'error';
    try {
      await _firestore.collection('users').doc(userId).update({
        'savedPosts': FieldValue.arrayRemove([postId])
      });
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }
}
