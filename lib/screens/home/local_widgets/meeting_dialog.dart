import 'package:flutter/material.dart';
import 'package:gangbook/models/meet.dart';
import 'package:gangbook/state_managment/current_gang.dart';
import 'package:provider/provider.dart';
import 'meeting_widgets/there_is_meeting.dart';
import 'meeting_widgets/there_is_no_meeting.dart';

class MeetingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentGang>(
      builder: (context, currentGang, child) {
        if (currentGang.gang.meetIds == null) return Container();
        return Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: currentGang.gang.meetIds.length + 1,
            itemBuilder: (ctx, i) {
              Widget child;
              if (i == currentGang.gang.meetIds.length)
                child = ThereIsNoMeeting();
              else
                child = Provider<Meet>.value(
                  value: currentGang.getMeetById(currentGang.gang.meetIds[i]),
                  child: ThereIsMeet(),
                );
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width - 60,
                  child: child,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
