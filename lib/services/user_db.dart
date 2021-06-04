import 'package:cloud_firestore/cloud_firestore.dart';

class UserDB {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
