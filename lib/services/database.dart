import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gangbook/models/app_gang.dart';
import 'package:gangbook/models/app_user.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/models/gang_member.dart';
import 'package:gangbook/models/meet.dart';

class AppDB {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createUser(AppUser user) async {
    String retVal = 'error';
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'fullname': user.fullName,
        'email': user.email,
        'createdAt': Timestamp.now(),
      });
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<AppUser> getUserInfoByUid(String uid) async {
    AppUser _user = AppUser();

    try {
      DocumentSnapshot _doc =
          await _firestore.collection('users').doc(uid).get();
      _user.uid = uid;
      _user.fullName = _doc.data()['fullname'];
      _user.email = _doc.data()['email'];
      _user.createdAt = _doc.data()['createdAt'];
      _user.gangId = _doc.data()['gangId'];
    } catch (e) {
      print(e);
      return null;
    }
    return _user;
  }

  Future<String> createGang(String gangName, AppUser user) async {
    String retVal = 'error';
    List<String> members = [];
    try {
      members.add(GangMember(user.uid, user.fullName).toJson());
      final _docRef = await _firestore.collection('gangs').add({
        'name': gangName,
        'leader': user.uid,
        'members': members,
        'createdAt': Timestamp.now(),
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

  Future<String> joinGang(String gangId, AppUser user) async {
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
      final meetId = gangData.data()['meetId'];
      if (meetId != null) {
        await _firestore
            .collection('gangs')
            .doc(gangId)
            .collection('meets')
            .doc(meetId)
            .update({
          'membersAreComming': FieldValue.arrayUnion(
            [
              EventMember(
                user.uid,
                user.fullName,
                ConfirmationType.HasntConfirmed,
                null,
              ).toJson(),
            ],
          ),
        });
      }
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<AppGang> getGangInfoById(String gangId) async {
    AppGang _gang = AppGang();
    final List<GangMember> members = [];

    try {
      DocumentSnapshot _doc =
          await _firestore.collection('gangs').doc(gangId).get();
      final List<dynamic> membersData = _doc.data()['members'];
      membersData.forEach((data) {
        members.add(GangMember.fromJson(data));
      });

      _gang.id = gangId;
      _gang.name = _doc.data()['name'];
      _gang.leader = _doc.data()['leader'];
      _gang.createdAt = _doc.data()['createdAt'];
      _gang.members = members;
      _gang.meetId = _doc.data()['meetId'];
    } catch (e) {
      print(e);
      return null;
    }
    return _gang;
  }

  Future<Meet> getMeetById(String gangId, String meetId) async {
    Meet _meet = Meet();
    List<EventMember> eventMembers = [];

    try {
      DocumentSnapshot _doc = await _firestore
          .collection('gangs')
          .doc(gangId)
          .collection('meets')
          .doc(meetId)
          .get();
      final List<dynamic> membersData = _doc.data()['membersAreComming'];
      membersData.forEach((data) {
        eventMembers.add(EventMember.fromJson(data));
      });
      _meet.id = meetId;
      _meet.title = _doc.data()['title'];
      _meet.location = _doc.data()['location'];
      _meet.moreInfo = _doc.data()['moreInfo'];
      _meet.meetingAt = _doc.data()['meetingAt'];
      _meet.createdAt = _doc.data()['createdAt'];
      _meet.membersAreComming = eventMembers;
    } catch (e) {
      print(e);
      return null;
    }
    return _meet;
  }

  Future<String> setNewMeet({
    @required String title,
    @required String location,
    @required String moreInfo,
    @required Timestamp meetingAt,
    @required AppUser user,
  }) async {
    String retVal = 'error';
    List<String> membersAreComming = [];
    try {
      final gang = await getGangInfoById(user.gangId);
      final json = EventMember(
        user.uid,
        user.fullName,
        ConfirmationType.Arrive,
        null,
      ).toJson();

      membersAreComming.add(
        EventMember(
          user.uid,
          user.fullName,
          ConfirmationType.Arrive,
          null,
        ).toJson(),
      );
      gang.members.forEach((gangMember) {
        if (gangMember.uid != user.uid) {
          membersAreComming.add(
            EventMember(
              gangMember.uid,
              gangMember.name,
              ConfirmationType.HasntConfirmed,
              null,
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

      await _firestore
          .collection('gangs')
          .doc(user.gangId)
          .update({'meetId': _docRef.id});

      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> meetAcception(
      {ConfirmationType isComming, AppUser user, Meet meet}) async {
    String retVal = 'error';
    meet.membersAreComming
        .firstWhere((eventMember) => eventMember.uid == user.uid)
        .isComming = isComming;
    final List<String> membersAreCommingJson = [];
    meet.membersAreComming.forEach((eventMember) {
      membersAreCommingJson.add(eventMember.toJson());
    });
    try {
      await _firestore
          .collection('gangs')
          .doc(user.gangId)
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

  Future<String> addCar({int places, AppUser user, Meet meet}) async {
    String retVal = 'error';
    meet.membersAreComming
        .firstWhere((eventMember) => eventMember.uid == user.uid)
        .car = Car(
      ownerId: user.uid,
      riders: [],
      places: places,
      requests: [],
    );
    final List<String> membersAreCommingJson = [];
    meet.membersAreComming.forEach((eventMember) {
      membersAreCommingJson.add(eventMember.toJson());
    });
    try {
      await _firestore
          .collection('gangs')
          .doc(user.gangId)
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

  Future<String> joinToCar({
    AppUser user,
    Meet meet,
    Car car,
    String pickUpFrom,
  }) async {
    String retVal = 'error';
    meet.membersAreComming
        .firstWhere((eventMember) => eventMember.uid == car.ownerId)
        .car
        .requests
        .add(CarRider(
          name: user.fullName,
          uid: user.uid,
          pickupFrom: pickUpFrom,
        ));
    final List<String> membersAreCommingJson = [];
    meet.membersAreComming.forEach((eventMember) {
      membersAreCommingJson.add(eventMember.toJson());
    });
    try {
      await _firestore
          .collection('gangs')
          .doc(user.gangId)
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

  Future<String> confirmRideRequest({
    String gangId,
    String riderUid,
    Meet meet,
    Car car,
    String pickUpFrom,
  }) async {
    String retVal = 'error';

    final requstList = meet.membersAreComming
        .firstWhere((eventMember) => eventMember.uid == car.ownerId)
        .car
        .requests;

    final ridersList = meet.membersAreComming
        .firstWhere((eventMember) => eventMember.uid == car.ownerId)
        .car
        .riders;

    final index = requstList.indexWhere((rider) => rider.uid == riderUid);

    final rider = requstList.elementAt(index);

    requstList.removeAt(index);

    ridersList.add(rider);

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
