import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gangbook/models/meet.dart';
import 'package:gangbook/state_managment/current_gang.dart';
import 'package:provider/provider.dart';
import 'meeting_widgets/there_is_meeting.dart';
import 'meeting_widgets/there_is_no_meeting.dart';

class MeetingDialog extends StatefulWidget {
  @override
  _MeetingDialogState createState() => _MeetingDialogState();
}

class _MeetingDialogState extends State<MeetingDialog> {
  final PageController controller = PageController();
  int currentPos = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentGang>(
      builder: (context, currentGang, child) {
        if (currentGang.gang.meetIds == null) return Container();
        return Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.45,
              child: PageView.builder(
                controller: controller,
                onPageChanged: (value) => setState(() {
                  currentPos = value;
                }),
                scrollDirection: Axis.horizontal,
                //shrinkWrap: true,
                itemCount: currentGang.gang.meetIds.length + 1,
                itemBuilder: (ctx, i) {
                  Widget child;
                  if (i == currentGang.gang.meetIds.length)
                    child = ThereIsNoMeeting();
                  else
                    child = Provider<Meet>.value(
                      value:
                          currentGang.getMeetById(currentGang.gang.meetIds[i]),
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
            ),
            SizedBox(height: 5),
            DotsIndicator(
              max: currentGang.gang.meetIds.length + 1,
              current: currentPos,
              animateToPage: (page) => controller.animateToPage(
                page,
                duration: Duration(milliseconds: 750),
                curve: Curves.fastOutSlowIn,
              ),
            ),
          ],
        );
      },
    );
  }
}

class DotsIndicator extends StatelessWidget {
  final int max;
  final int current;
  final void Function(int) animateToPage;

  DotsIndicator({this.max, this.current, this.animateToPage});

  Widget _buildRadioButton(BuildContext context, int index) {
    final screenSize = MediaQuery.of(context).size;
    final size = min((screenSize.width * 0.04), 20.0);

    return GestureDetector(
      onTap: () {
        animateToPage(index);
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.01,
        ),
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: index == current
              ? Theme.of(context).secondaryHeaderColor
              : Colors.transparent,
          // לכפתור יהיה מסגרת ככה שיהיה בולט גם כשהוא שקוף
          border: Border.all(
            width: 2,
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),
      ),
    );
  }

  Widget _buildRadioButtonsList(BuildContext context) {
    List<Widget> buttons = [];
    for (int i = 0; i < max; i++) {
      buttons.add(_buildRadioButton(context, i));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttons,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildRadioButtonsList(context);
  }
}
