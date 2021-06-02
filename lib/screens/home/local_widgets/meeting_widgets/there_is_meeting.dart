import 'package:flutter/material.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/models/gang_model.dart';
import 'package:gangbook/models/meet_model.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/screens/home/local_widgets/meeting_widgets/meeting_timer.dart';
import 'package:gangbook/screens/home/local_widgets/meeting_widgets/user_arrival_control_buttons.dart';
import 'package:gangbook/services/meets_db.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:gangbook/state_managment/meet_state.dart';
import 'package:gangbook/widgets/whiteRoundedCard.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'event_members_arriving_list.dart';

class ThereIsMeet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<UserModel>(context, listen: false);
    final _currentGang = Provider.of<GangState>(context, listen: false);
    final _meet = Provider.of<MeetState>(context);

    return WhiteRoundedCard(
      child: Container(
        alignment: Alignment.center,
        child: _meet == null
            ? CircularProgressIndicator.adaptive()
            : Scrollbar(
                radius: Radius.circular(30),
                thickness: 6,
                child: SingleChildScrollView(
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _meet.meet.title,
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _meet.meet.location,
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                          ),
                          SizedBox(height: 10),
                          if (_meet.meet.moreInfo.isNotEmpty)
                            Text(
                              _meet.meet.moreInfo,
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
                                    .format(_meet.meet.meetingAt.toDate()),
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          MeetingTimer(_meet.meet.meetingAt.toDate()),
                          SizedBox(height: 10),
                          UserArrivalControlButtons(),
                          SizedBox(height: 10),
                          if (_meet.eventMemberById(_currentUser.uid).car !=
                              null) ...[
                            if (_meet
                                .eventMemberById(_currentUser.uid)
                                .car
                                .requests
                                .isNotEmpty)
                              Text(
                                'Car join requests',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ..._buildApproveRiders(
                              _meet.eventMemberById(_currentUser.uid),
                              _meet,
                            ),
                          ]
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
                                  builder: (_) => EvetMembersArrivingList(
                                    currentGang: _currentGang.gang,
                                    meet: _meet,
                                    user: _currentUser,
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
                ),
              ),
      ),
    );
  }

  List<Widget> _buildApproveRiders(EventMember eventMember, MeetState meet) {
    return eventMember.car.requests
        .map(
          (rider) => ListTile(
            title: Text(rider.name),
            subtitle: Text(rider.pickupFrom ?? ' '),
            trailing: OutlinedButton(
                onPressed: () async {
                  await meet.confirmCarRideRequest(
                    rider.uid,
                    eventMember.car,
                    rider.pickupFrom ?? '',
                  );
                },
                child: Text(
                  'add',
                  style: TextStyle(color: Colors.black),
                )),
          ),
        )
        .toList();
  }
}
