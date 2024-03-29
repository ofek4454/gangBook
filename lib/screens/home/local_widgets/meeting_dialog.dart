import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gangbook/services/database_streams.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:gangbook/state_managment/meet_state.dart';
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
    final cardHeight = MediaQuery.of(context).size.height * 0.45;
    return Consumer<GangState>(
      builder: (context, currentGang, child) {
        if (currentGang == null || currentGang.gang.meetIds == null)
          return Container();
        return Column(
          children: [
            currentGang.gang.meetIds.isEmpty
                ? ThereIsNoMeeting()
                : Container(
                    width: double.infinity,
                    height: cardHeight,
                    child: PageView.builder(
                      controller: controller,
                      onPageChanged: (value) => setState(() {
                        currentPos = value;
                      }),
                      scrollDirection: Axis.horizontal,
                      itemCount: currentGang.gang.meetIds.length + 1,
                      itemBuilder: (ctx, i) {
                        Widget child;
                        if (i == currentGang.gang.meetIds.length)
                          child = ThereIsNoMeeting();
                        else
                          child = StreamProvider<MeetState>.value(
                            initialData: null,
                            value: DBStreams().getMeet(
                                currentGang.gang.meetIds[i],
                                currentGang.gang.id),
                            child: ThereIsMeet(),
                          );
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Container(
                            width: MediaQuery.of(context).size.width - 60,
                            child: child,
                          ),
                        );
                      },
                    ),
                  ),
            SizedBox(height: 5),
            if (currentGang.gang.meetIds.isNotEmpty)
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
