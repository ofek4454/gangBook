import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/models/gang_member.dart';
import 'package:gangbook/models/gang_model.dart';
import 'package:gangbook/models/meet_model.dart';
import 'package:gangbook/models/user_model.dart';

class MeetDB {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<MeetModel> getMeetById(String gangId, String meetId) async {
    try {
      DocumentSnapshot _doc = await _firestore
          .collection('gangs')
          .doc(gangId)
          .collection('meets')
          .doc(meetId)
          .get();
      return MeetModel.fromDocumentSnapshot(_doc);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<MeetModel>> getMeetsHistory(String gangId) async {
    List<MeetModel> _meets = [];

    try {
      final meetsCollection = await _firestore
          .collection('gangs')
          .doc(gangId)
          .collection('meets')
          .orderBy('createdAt')
          .get();

      for (final meetData in meetsCollection.docs) {
        final meet = await getMeetById(gangId, meetData.id);
        _meets.insert(0, meet);
      }
    } catch (e) {
      print(e);
      return null;
    }
    return _meets;
  }

  Future<String> setNewMeet({
    @required String title,
    @required String location,
    @required String moreInfo,
    @required Timestamp meetingAt,
    @required UserModel user,
    @required GangModel gang,
    @required GangMember createBy,
  }) async {
    String retVal = 'error';
    List<String> membersAreComming = [];
    try {
      final json = EventMember(
        uid: user.uid,
        name: user.fullName,
        isComming: ConfirmationType.Arrive,
        car: null,
        carRequests: [],
        carRide: null,
      ).toJson();

      membersAreComming.add(json);
      gang.members.forEach((gangMember) {
        if (gangMember.uid != user.uid) {
          membersAreComming.add(
            EventMember(
              uid: gangMember.uid,
              name: gangMember.name,
              isComming: ConfirmationType.HasntConfirmed,
              car: null,
              carRequests: [],
              carRide: null,
            ).toJson(),
          );
        }
      });
      DocumentReference _docRef = await _firestore
          .collection('gangs')
          .doc(user.gangId)
          .collection('meets')
          .add({
        'title': title,
        'location': location,
        'moreInfo': moreInfo,
        'meetingAt': meetingAt,
        'membersAreComming': membersAreComming,
        'createdAt': Timestamp.now(),
        'createBy': createBy.toJson(),
      });

      await _firestore.collection('gangs').doc(user.gangId).update({
        'meetIds': FieldValue.arrayUnion([_docRef.id])
      });

      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> updateMeeting({
    String gangId,
    MeetModel meet,
  }) async {
    String retVal = 'error';

    final List<String> membersAreCommingJson = [];
    meet.membersAreComming.forEach((eventMember) {
      membersAreCommingJson.add(eventMember.toJson());
    });
    try {
      await _firestore
          .collection('gangs')
          .doc(gangId)
          .collection('meets')
          .doc(meet.id)
          .update({
        'membersAreComming': membersAreCommingJson,
      });
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }
}
