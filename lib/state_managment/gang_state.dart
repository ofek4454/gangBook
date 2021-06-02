import 'package:gangbook/models/gang_model.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/services/meets_db.dart';
import 'package:gangbook/services/gang_db.dart';
import 'package:gangbook/state_managment/meet_state.dart';

class GangState {
  GangModel _gang;

  GangState(this._gang);

  GangModel get gang => _gang;

  Future<String> leaveGang(UserModel user) async {
    String retVal = 'error';
    try {
      for (final meetId in _gang.meetIds) {
        final meetModel = await MeetDB().getMeetById(_gang.id, meetId);
        final meet = MeetState(meetModel, _gang.id);

        await meet.removeEventMember(user.uid);
      }

      await GangDB().leaveGang(gangId: _gang.id, user: user);

      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }
}