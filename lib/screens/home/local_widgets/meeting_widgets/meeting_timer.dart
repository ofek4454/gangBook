import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gangbook/utils/time_left.dart';

class MeetingTimer extends StatefulWidget {
  final DateTime meetingDateTime;

  MeetingTimer(this.meetingDateTime);

  @override
  _MeetingTimerState createState() => _MeetingTimerState();
}

class _MeetingTimerState extends State<MeetingTimer> {
  Timer timer;
  String timeLeft;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft = TimeLeft().timeLeft(widget.meetingDateTime);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return timeLeft == null
        ? CircularProgressIndicator.adaptive()
        : FittedBox(
            child: Text(timeLeft),
          );
  }
}
