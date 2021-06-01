import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gangbook/models/gang_model.dart';
import 'package:gangbook/models/meet_model.dart';
import 'package:gangbook/models/user_model.dart';

class DBStreams {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<UserModel> getCurrentUser(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => UserModel.fromDocumentSnapshot(doc));
  }

  Stream<GangModel> getCurrentGang(String gangId) {
    return _firestore
        .collection('gangs')
        .doc(gangId)
        .snapshots()
        .map((doc) => GangModel.fromDocumentSnapshot(doc));
  }

  Stream<MeetModel> getMeet(String meetId, String gangId) {
    return _firestore
        .collection('gangs')
        .doc(gangId)
        .collection('meets')
        .doc(meetId)
        .snapshots()
        .map((doc) => MeetModel.fromDocumentSnapshot(doc));
  }
}
