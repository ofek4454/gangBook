import 'package:flutter/material.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/models/meet.dart';
import 'package:gangbook/screens/home/local_widgets/meeting_widgets/meeting_timer.dart';
import 'package:gangbook/screens/home/local_widgets/meeting_widgets/user_arrival_control_buttons.dart';
import 'package:gangbook/state_managment/current_gang.dart';
import 'package:gangbook/state_managment/current_user.dart';
import 'package:gangbook/widgets/whiteRoundedCard.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'event_members_arriving_list.dart';

class ThereIsMeet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<CurrentUser>(context, listen: false);
    final _currentGang = Provider.of<CurrentGang>(context, listen: false);
    final _meet = Provider.of<Meet>(context, listen: false);

    return WhiteRoundedCard(
      child: Container(
        alignment: Alignment.center,
        child: Scrollbar(
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
                      _meet.title ?? 'loading...',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _meet.location ?? 'loading...',
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    if (_meet.moreInfo.isNotEmpty)
                      Text(
                        _meet.moreInfo ?? 'loading...',
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
                                  .format(_meet.meetingAt?.toDate()) ??
                              'loading...',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    MeetingTimer(_meet.meetingAt.toDate()),
                    SizedBox(height: 10),
                    UserArrivalControlButtons(),
                    SizedBox(height: 10),
                    if (_currentGang
                            .eventMemberById(_currentUser.user.uid, _meet.id)
                            .car !=
                        null) ...[
                      if (_currentGang
                          .eventMemberById(_currentUser.user.uid, _meet.id)
                          .car
                          .requests
                          .isNotEmpty)
                        Text(
                          'Car join requests',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ..._buildApproveRiders(
                        _currentGang.eventMemberById(
                            _currentUser.user.uid, _meet.id),
                        _currentGang,
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
                              currentGang: _currentGang,
                              meet: _meet,
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

  List<Widget> _buildApproveRiders(
      EventMember eventMember, CurrentGang currentGang, Meet meet) {
    return eventMember.car.requests
        .map(
          (rider) => ListTile(
            title: Text(rider.name),
            subtitle: Text(rider.pickupFrom ?? ' '),
            trailing: OutlinedButton(
                onPressed: () async {
                  await currentGang.confirmCarRideRequest(
                    rider.uid,
                    meet,
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
