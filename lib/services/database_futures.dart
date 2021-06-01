import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/models/gang_member.dart';
import 'package:gangbook/models/gang_model.dart';
import 'package:gangbook/models/meet_model.dart';
import 'package:gangbook/models/user_model.dart';

class DBFutures {
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

  Future<String> leaveGang({GangModel gang, UserModel user}) async {
    String retVal = 'error';
    try {
      for (final meetId in gang.meetIds) {
        final meet = await getMeetById(gang.id, meetId);
        final eventMember = meet.eventMemberById(user.uid);
        final car = eventMember.car;

        if (car != null) {
          car.requests.forEach((rider) {
            meet.membersAreComming.forEach((member) {
              if (rider.uid == member.uid)
                member.carRequests.remove(car.ownerId);
            });
          });

          car.riders.forEach((rider) {
            meet.membersAreComming.forEach((member) {
              if (rider.uid == member.uid) member.carRide = null;
            });
          });

          eventMember.car = null;
        }
        eventMember.carRequests.forEach((ownerId) {
          meet.membersAreComming
              .firstWhere((member) => member.uid == ownerId)
              .carRequests
              .removeWhere((riderId) => riderId == user.uid);
        });
        if (eventMember.carRide != null) {
          meet.membersAreComming
              .firstWhere((member) => member.uid == eventMember.carRide)
              .car
              .riders
              .removeWhere((rider) => rider.uid == user.uid);
        }
        meet.membersAreComming.removeWhere((member) => member.uid == user.uid);
        await updateMeeting(gangId: gang.id, meet: meet);
      }

      await _firestore.collection('gangs').doc(gang.id).update({
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

  Future<String> setNewMeet(
      {@required String title,
      @required String location,
      @required String moreInfo,
      @required Timestamp meetingAt,
      @required UserModel user,
      @required GangModel gang}) async {
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
