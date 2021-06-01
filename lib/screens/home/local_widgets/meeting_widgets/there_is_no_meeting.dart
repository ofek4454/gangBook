import 'package:flutter/material.dart';
import 'package:gangbook/models/gang_model.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/screens/schedule_new_meeting/schedule_new_meeting_screen.dart';
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
          Provider.of<GangModel>(context, listen: false),
          Provider.of<UserModel>(context, listen: false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool haveMoreMeetings = false;
    if (Provider.of<GangModel>(context, listen: false).meetIds.isNotEmpty)
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
