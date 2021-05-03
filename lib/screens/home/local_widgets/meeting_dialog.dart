import 'package:flutter/material.dart';
import 'package:gangbook/state_managment/current_gang.dart';
import 'package:provider/provider.dart';
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
