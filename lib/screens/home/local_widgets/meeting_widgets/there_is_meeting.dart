import 'package:flutter/material.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/models/gang_model.dart';
import 'package:gangbook/models/meet_model.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/screens/home/local_widgets/meeting_widgets/meeting_timer.dart';
import 'package:gangbook/screens/home/local_widgets/meeting_widgets/user_arrival_control_buttons.dart';
import 'package:gangbook/services/database_futures.dart';
import 'package:gangbook/widgets/whiteRoundedCard.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'event_members_arriving_list.dart';

class ThereIsMeet extends StatelessWidget {
  Future<void> confirmCarRideRequest({
    String riderUid,
    MeetModel meet,
    Car car,
    String pickUpFrom,
    String gangId,
  }) async {
    final requstList = car.requests;

    final ridersList = car.riders;

    final index = requstList.indexWhere((rider) => rider.uid == riderUid);

    final rider = requstList.elementAt(index);

    requstList.removeAt(index);

    ridersList.add(rider);

    final riderEventMember = meet.eventMemberById(riderUid);

    riderEventMember.carRequests.remove(car.ownerId);
    riderEventMember.carRequests?.forEach((carOwnerId) {
      meet
          .eventMemberById(carOwnerId)
          .car
          .requests
          .removeWhere((carRider) => carRider.uid == riderEventMember.uid);
    });

    riderEventMember.carRequests.clear();
    riderEventMember.carRide = car.ownerId;

    await DBFutures().updateMeeting(gangId: gangId, meet: meet);
  }

  @override
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<UserModel>(context, listen: false);
    final _currentGang = Provider.of<GangModel>(context, listen: false);
    final _meet = Provider.of<MeetModel>(context);

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
                            _meet.title,
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _meet.location,
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                          ),
                          SizedBox(height: 10),
                          if (_meet.moreInfo.isNotEmpty)
                            Text(
                              _meet.moreInfo,
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
                                    .format(_meet.meetingAt.toDate()),
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

  List<Widget> _buildApproveRiders(
      EventMember eventMember, GangModel currentGang, MeetModel meet) {
    return eventMember.car.requests
        .map(
          (rider) => ListTile(
            title: Text(rider.name),
            subtitle: Text(rider.pickupFrom ?? ' '),
            trailing: OutlinedButton(
                onPressed: () async {
                  await confirmCarRideRequest(
                      riderUid: rider.uid,
                      meet: meet,
                      car: eventMember.car,
                      pickUpFrom: rider.pickupFrom ?? '',
                      gangId: currentGang.id);
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
