import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gangbook/models/chat_model.dart';
import 'package:gangbook/models/gang_model.dart';
import 'package:gangbook/models/meet_model.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/state_managment/chat_state.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:gangbook/state_managment/meet_state.dart';
import 'package:gangbook/state_managment/user_state.dart';

class DBStreams {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<UserState> getCurrentUser(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => UserState(UserModel.fromDocumentSnapshot(doc)));
  }

  Stream<GangState> getCurrentGang(String gangId) {
    return _firestore
        .collection('gangs')
        .doc(gangId)
        .snapshots()
        .map((doc) => GangState(GangModel.fromDocumentSnapshot(doc)));
  }

  Stream<MeetState> getMeet(String meetId, String gangId) {
    return _firestore
        .collection('gangs')
        .doc(gangId)
        .collection('meets')
        .doc(meetId)
        .snapshots()
        .map((doc) => MeetState(MeetModel.fromDocumentSnapshot(doc), gangId));
  }

  Stream<ChatState> getChat(String gangId) {
    return _firestore
        .collection('gangs')
        .doc(gangId)
        .collection('chat')
        .snapshots()
        .map((chatCollection) =>
            ChatState(ChatModel.fromQuerySnapshot(chatCollection)));
  }
}
