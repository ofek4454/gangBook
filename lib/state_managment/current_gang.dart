import 'package:flutter/material.dart';
import 'package:gangbook/models/app_gang.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/models/meet.dart';
import 'package:gangbook/services/database.dart';

class CurrentGang extends ChangeNotifier {
  AppGang _gang = AppGang();
  Meet _meet;

  AppGang get gang => _gang;
  Meet get meet => _meet;

  void updateStateFromDB(String gangId) async {
    try {
      _gang = await AppDB().getGangInfoById(gangId);
      if (_gang.meetId != null) {
        _meet = await AppDB().getMeetById(gangId, _gang.meetId);
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  EventMember eventMemberById(String uid) {
    final EventMember eventMember =
        _meet.membersAreComming.firstWhere((member) => member.uid == uid);
    return eventMember;
  }
}
