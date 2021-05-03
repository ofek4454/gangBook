import 'package:flutter/material.dart';
import 'package:gangbook/screens/schedule_new_meeting/schedule_new_meeting_screen.dart';
import 'package:gangbook/widgets/whiteRoundedCard.dart';

class ThereIsNoMeeting extends StatelessWidget {
  const ThereIsNoMeeting({
    Key key,
  }) : super(key: key);

  void _scheduleMeeting(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScheduleNewMeetingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WhiteRoundedCard(
      child: Column(
        children: [
          Text(
            'There is no meeting scheduled',
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).secondaryHeaderColor,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: RaisedButton(
                  onPressed: () => _scheduleMeeting(context),
                  child: Text(
                    'Schedule meeting',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
