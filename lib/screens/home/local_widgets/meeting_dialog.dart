import 'package:flutter/material.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/screens/schedule_new_meeting/schedule_new_meeting_screen.dart';
import 'package:gangbook/services/database.dart';
import 'package:gangbook/state_managment/current_gang.dart';
import 'package:gangbook/state_managment/current_user.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../widgets/whiteRoundedCard.dart';

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

class ThereIsMeet extends StatelessWidget {
  const ThereIsMeet({
    Key key,
  }) : super(key: key);

  Future<void> _meetAcception(
      BuildContext context, ConfirmationType isCommig) async {
    final _currentUser = Provider.of<CurrentUser>(context, listen: false);
    final _currentGang = Provider.of<CurrentGang>(context, listen: false);

    final result = await AppDB().meetAcception(
      isComming: isCommig,
      user: _currentUser.user,
      meet: _currentGang.meet,
    );
    if (result == 'success') {
      _currentGang.updateStateFromDB(_currentGang.gang.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<CurrentUser>(context, listen: false);
    final _currentGang = Provider.of<CurrentGang>(context, listen: false);
    final userIsComming =
        _currentGang.meet.userAreComming(_currentUser.user.uid);
    print(_currentGang.meet.membersAreComming);

    return WhiteRoundedCard(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _currentGang.meet.title ?? 'loading...',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Text(
                _currentGang.meet.location ?? 'loading...',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
              SizedBox(height: 10),
              Text(
                _currentGang.meet.moreInfo ?? 'loading...',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Due in: ',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                  Text(
                    DateFormat('dd/MM/yy HH:mm')
                            .format(_currentGang.meet.meetingAt?.toDate()) ??
                        'loading...',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              userIsComming != ConfirmationType.HasntConfirmed
                  ? OutlinedButton(
                      onPressed: () {
                        if (userIsComming == ConfirmationType.Arrive)
                          _meetAcception(
                            context,
                            ConfirmationType.NotArrive,
                          );
                        else
                          _meetAcception(
                            context,
                            ConfirmationType.Arrive,
                          );
                      },
                      child: Text(
                        userIsComming == ConfirmationType.Arrive
                            ? 'You are comming! click to change'
                            : 'You are\'t comming! click to change',
                        style: TextStyle(
                          color: userIsComming == ConfirmationType.Arrive
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: RaisedButton(
                            onPressed: () => _meetAcception(
                              context,
                              ConfirmationType.Arrive,
                            ),
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: Theme.of(context).secondaryHeaderColor,
                                width: 3,
                              ),
                            ),
                            child: Text(
                              'Coming',
                              style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: RaisedButton(
                            onPressed: () => _meetAcception(
                              context,
                              ConfirmationType.NotArrive,
                            ),
                            child: Text(
                              'Not coming',
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
          Positioned(
            left: -10,
            top: -10,
            child: ClipOval(
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: ListView.builder(
                          itemCount: _currentGang.meet.membersAreComming.length,
                          itemBuilder: (ctx, i) {
                            Color textColor;
                            switch (_currentGang
                                .meet.membersAreComming[i].isComming) {
                              case ConfirmationType.Arrive:
                                textColor = Colors.green;
                                break;
                              case ConfirmationType.NotArrive:
                                textColor = Colors.red;
                                break;
                              case ConfirmationType.HasntConfirmed:
                                textColor = Colors.orange;
                                break;
                              default:
                                textColor = Colors.orange;
                                break;
                            }
                            return Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: Center(
                                child: Text(
                                  _currentGang.meet.membersAreComming[i].name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.people_alt_outlined),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
