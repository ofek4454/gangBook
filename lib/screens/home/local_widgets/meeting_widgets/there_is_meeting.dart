import 'package:flutter/material.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/screens/home/local_widgets/meeting_widgets/user_arrival_control_buttons.dart';
import 'package:gangbook/services/database.dart';
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
              UserArrivalControlButtons(),
              if (_currentGang.eventMemberById(_currentUser.user.uid).car !=
                  null) ...[
                if (_currentGang
                    .eventMemberById(_currentUser.user.uid)
                    .car
                    .requests
                    .isNotEmpty)
                  Text(
                    'Car join requests',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ..._buildApproveRiders(
                  _currentGang.eventMemberById(_currentUser.user.uid),
                  _currentGang,
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
                      builder: (_) => EvetMembersArrivingList(),
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

  List<Widget> _buildApproveRiders(
      EventMember eventMember, CurrentGang currentGang) {
    return eventMember.car.requests
        .map(
          (rider) => ListTile(
            title: Text(rider.name),
            subtitle: Text(rider.pickupFrom ?? ''),
            trailing: OutlinedButton(
                onPressed: () {
                  AppDB()
                      .confirmRideRequest(
                        car: eventMember.car,
                        gangId: currentGang.gang.id,
                        meet: currentGang.meet,
                        pickUpFrom: '',
                        riderUid: rider.uid,
                      )
                      .then((value) =>
                          currentGang.updateStateFromDB(currentGang.gang.id));
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