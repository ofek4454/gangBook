import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gangbook/models/app_user.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/models/meet.dart';
import 'package:gangbook/screens/schedule_new_meeting/schedule_new_meeting_screen.dart';
import 'package:gangbook/services/database.dart';
import 'package:gangbook/state_managment/current_gang.dart';
import 'package:gangbook/state_managment/current_user.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../widgets/whiteRoundedCard.dart';
import 'meeting_widgets/there_is_meeting.dart';
import 'meeting_widgets/there_is_no_meeting.dart';

class MeetingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentGang>(
      builder: (context, value, child) {
        if (value.meet != null) {
          return ThereIsMeet();
        } else {
          return ThereIsNoMeeting();
        }
      },
    );
  }
}
