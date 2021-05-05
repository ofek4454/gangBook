import 'package:flutter/material.dart';
import 'package:gangbook/models/app_gang.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/models/meet.dart';
import 'package:gangbook/services/database.dart';

class CurrentGang extends ChangeNotifier {
  AppGang _gang = AppGang();
  List<Meet> _meets = [];

  AppGang get gang => _gang;
  Meet getMeetById(String meetId) {
    return _meets.firstWhere((meet) => meet.id == meetId);
  }

  Future<void> updateStateFromDB(String gangId) async {
    try {
      _gang = await AppDB().getGangInfoById(gangId);
      if (_gang.meetIds != null && _gang.meetIds.isNotEmpty) {
        for (String meetId in _gang.meetIds) {
          final meet = await AppDB().getMeetById(gangId, meetId);
          _meets.add(meet);
        }
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  EventMember eventMemberById(String uid, String meetId) {
    final meet = getMeetById(meetId);
    final EventMember eventMember =
        meet.membersAreComming.firstWhere((member) => member.uid == uid);
    return eventMember;
  }
}
