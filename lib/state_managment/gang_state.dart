import 'dart:io';

import 'package:gangbook/models/gang_member.dart';
import 'package:gangbook/models/gang_model.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/services/cloudinary_requests.dart';
import 'package:gangbook/services/meets_db.dart';
import 'package:gangbook/services/gang_db.dart';
import 'package:gangbook/state_managment/meet_state.dart';

class GangState {
  GangModel _gang;

  GangState(this._gang);

  GangModel get gang => _gang;

  Future<void> changeGangImage(File image) async {
    if (_gang.gangImage != null) {
      await CloudinaryRequests().deleteIFile(_gang.gangImage);
    }
    final imageUrl =
        await CloudinaryRequests().uploadGangImage(image, _gang.id);

    await GangDB().updateGangImage(_gang.id, imageUrl);
  }

  Future<String> chaneGangPrivacyMode(bool isPrivate) async {
    String retVal = 'error';
    try {
      await GangDB().changeGangPrivacyMode(_gang.id, isPrivate);

      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> denieJoinRequest(String uid) async {
    String retVal = 'error';
    try {
      await GangDB().denieJoinRequest(_gang.id, uid);

      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> approveJoinRequest(String uid) async {
    String retVal = 'error';
    try {
      await GangDB().approveRequestToJoinGang(_gang.id, uid);

      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> leaveGang(UserModel user, String newLeaderUid) async {
    String retVal = 'error';
    try {
      for (final meetId in _gang.meetIds) {
        final meetModel = await MeetDB().getMeetById(_gang.id, meetId);
        final meet = MeetState(meetModel, _gang.id);

        await meet.removeEventMember(user.uid);
      }
      if (newLeaderUid != null) {
        await GangDB().replaceLeader(_gang.id, newLeaderUid);
      }
      await GangDB().leaveGang(gangId: _gang.id, user: user);

      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> kikOutFromGang(GangMember member) async {
    String retVal = 'error';
    try {
      for (final meetId in _gang.meetIds) {
        final meetModel = await MeetDB().getMeetById(_gang.id, meetId);
        final meet = MeetState(meetModel, _gang.id);

        await meet.removeEventMember(member.uid);
      }

      await GangDB().kikOutFromGang(gangId: _gang.id, member: member);

      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }
}
