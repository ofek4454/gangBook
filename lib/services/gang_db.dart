import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/models/gang_member.dart';
import 'package:gangbook/models/user_model.dart';

class GangDB {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createGang(String gangName, UserModel user) async {
    String retVal = 'error';
    List<String> members = [];

    try {
      members.add(GangMember(user.uid, user.fullName).toJson());

      final _docRef = await _firestore.collection('gangs').add({
        'name': gangName,
        'leader': user.uid,
        'members': members,
        'createdAt': Timestamp.now(),
        'meetIds': [],
        'isPrivate': false,
      });
      await _firestore.collection('users').doc(user.uid).update({
        'gangId': _docRef.id,
      });
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> joinOrRequest(String gangId, UserModel user) async {
    String retVal = 'error';
    try {
      final gangDoc = await _firestore.collection('gangs').doc(gangId).get();
      final isPrivate = gangDoc.data()['isPrivate'];

      if (isPrivate) {
        retVal = await requestJoinGang(gangId, user.uid);
      } else {
        retVal = await joinGang(gangId, user);
      }
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> requestJoinGang(String gangId, String uid) async {
    String retVal = 'error';
    try {
      await _firestore.collection('gangs').doc(gangId).update({
        'joinRequests': FieldValue.arrayUnion([uid])
      });

      await _firestore.collection('users').doc(uid).update({
        'gangJoinRequest': gangId,
      });

      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> denieJoinRequest(String gangId, String uid) async {
    String retVal = 'error';
    try {
      await _firestore.collection('gangs').doc(gangId).update({
        'joinRequests': FieldValue.arrayRemove([uid])
      });

      await _firestore.collection('users').doc(uid).update({
        'gangJoinRequest': null,
      });

      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> approveRequestToJoinGang(String gangId, String uid) async {
    String retVal = 'error';
    List<String> members = [];

    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userName = userDoc.data()['fullname'];
      members.add(GangMember(uid, userName).toJson());
      await _firestore.collection('gangs').doc(gangId).update({
        'members': FieldValue.arrayUnion(members),
        'joinRequests': FieldValue.arrayRemove([uid]),
      });
      await _firestore.collection('users').doc(uid).update({
        'gangId': gangId,
        'gangJoinRequest': null,
      });
      final gangData = await _firestore.collection('gangs').doc(gangId).get();
      final List<dynamic> meetIds = gangData.data()['meetIds'] ?? [];
      if (meetIds.isNotEmpty) {
        for (String meetId in meetIds) {
          await _firestore
              .collection('gangs')
              .doc(gangId)
              .collection('meets')
              .doc(meetId)
              .update({
            'membersAreComming': FieldValue.arrayUnion(
              [
                EventMember(
                  uid: uid,
                  name: userName,
                  isComming: ConfirmationType.HasntConfirmed,
                  car: null,
                  carRequests: [],
                  carRide: null,
                ).toJson(),
              ],
            ),
          });
        }
      }
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> joinGang(String gangId, UserModel user) async {
    String retVal = 'error';
    List<String> members = [];
    try {
      members.add(GangMember(user.uid, user.fullName).toJson());
      await _firestore.collection('gangs').doc(gangId).update({
        'members': FieldValue.arrayUnion(members),
      });
      await _firestore.collection('users').doc(user.uid).update({
        'gangId': gangId,
      });
      final gangData = await _firestore.collection('gangs').doc(gangId).get();
      final List<dynamic> meetIds = gangData.data()['meetIds'] ?? [];
      if (meetIds.isNotEmpty) {
        for (String meetId in meetIds) {
          await _firestore
              .collection('gangs')
              .doc(gangId)
              .collection('meets')
              .doc(meetId)
              .update({
            'membersAreComming': FieldValue.arrayUnion(
              [
                EventMember(
                  uid: user.uid,
                  name: user.fullName,
                  isComming: ConfirmationType.HasntConfirmed,
                  car: null,
                  carRequests: [],
                  carRide: null,
                ).toJson(),
              ],
            ),
          });
        }
      }
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> leaveGang({String gangId, UserModel user}) async {
    String retVal = 'error';
    try {
      await _firestore.collection('gangs').doc(gangId).update({
        'members': FieldValue.arrayRemove(
            [GangMember(user.uid, user.fullName).toJson()]),
      });
      await _firestore.collection('users').doc(user.uid).update({
        'gangId': null,
      });

      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> getGangName(String gangId) async {
    String retVal = 'error';
    try {
      final gangDoc = await _firestore.collection('gangs').doc(gangId).get();

      retVal = gangDoc.data()['name'];
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> changeGangPrivacyMode(String gangId, bool isPrivate) async {
    String retVal = 'error';
    try {
      await _firestore
          .collection('gangs')
          .doc(gangId)
          .update({'isPrivate': isPrivate});

      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }
}
