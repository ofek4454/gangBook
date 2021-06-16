import 'package:flutter/material.dart';
import 'package:gangbook/models/gang_model.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/screens/schedule_new_meeting/schedule_new_meeting_screen.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:gangbook/state_managment/user_state.dart';
import 'package:gangbook/widgets/whiteRoundedCard.dart';
import 'package:provider/provider.dart';

class ThereIsNoMeeting extends StatelessWidget {
  const ThereIsNoMeeting({
    Key key,
  }) : super(key: key);

  void _scheduleMeeting(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScheduleNewMeetingScreen(
          Provider.of<GangState>(context, listen: false).gang,
          Provider.of<UserState>(context, listen: false).user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool haveMoreMeetings = false;
    if (Provider.of<GangState>(context, listen: false).gang.meetIds.isNotEmpty)
      haveMoreMeetings = true;
    return Center(
      child: WhiteRoundedCard(
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                haveMoreMeetings
                    ? 'Add new meet'
                    : 'There is no meeting scheduled',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              RaisedButton(
                onPressed: () => _scheduleMeeting(context),
                child: Text(
                  haveMoreMeetings ? 'Add' : 'Schedule meeting',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
