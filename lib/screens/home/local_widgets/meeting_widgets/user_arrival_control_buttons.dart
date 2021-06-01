import 'package:flutter/material.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/models/gang_model.dart';
import 'package:gangbook/models/meet_model.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/screens/home/local_widgets/meeting_widgets/car_owner_controllers.dart';
import 'package:gangbook/services/database_futures.dart';
import 'package:provider/provider.dart';

class UserArrivalControlButtons extends StatelessWidget {
  Future<void> _meetAcception(
      BuildContext context, ConfirmationType isComming) async {
    final _currentUser = Provider.of<UserModel>(context, listen: false);
    final _currentGang = Provider.of<GangModel>(context, listen: false);
    final _meet = Provider.of<MeetModel>(context, listen: false);

    final eventMember = _meet.eventMemberById(_currentUser.uid);
    eventMember.isComming = isComming;
    if (isComming == ConfirmationType.NotArrive && eventMember.car != null) {
      removeCar(eventMember.car, _meet);
    }

    await DBFutures().updateMeeting(
      gangId: _currentGang.id,
      meet: _meet,
    );
  }

  Future<void> addCar(BuildContext context, int places) async {
    final user = Provider.of<UserModel>(context, listen: false);
    final meet = Provider.of<MeetModel>(context, listen: false);

    final eventMember = meet.eventMemberById(user.uid);
    eventMember.car = Car(
      ownerId: user.uid,
      riders: [],
      places: places,
      requests: [],
    );

    eventMember.carRequests?.forEach((carOwnerId) {
      meet.membersAreComming
          .firstWhere((eventMember) => eventMember.uid == carOwnerId)
          .car
          .requests
          .removeWhere((carRider) => carRider.uid == eventMember.uid);
    });

    eventMember.carRequests.clear();
    await DBFutures().updateMeeting(gangId: user.gangId, meet: meet);
  }

  void removeCar(Car car, MeetModel meet) {
    car.requests.forEach((rider) {
      meet.membersAreComming.forEach((member) {
        if (rider.uid == member.uid) member.carRequests.remove(car.ownerId);
      });
    });

    car.riders.forEach((rider) {
      meet.membersAreComming.forEach((member) {
        if (rider.uid == member.uid) member.carRide = null;
      });
    });

    final eventMember = meet.eventMemberById(car.ownerId);
    eventMember.car = null;
  }

  @override
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<UserModel>(context, listen: false);
    final _meet = Provider.of<MeetModel>(context, listen: false);

    final userIsComming = _meet.userAreComming(_currentUser.uid);

    return userIsComming != ConfirmationType.HasntConfirmed
        ? buildUserConfirmedArrival(context)
        : buildUserHasntConfirmed(context);
  }

  Row buildUserHasntConfirmed(BuildContext context) {
    return Row(
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
    );
  }

  Future<void> addCarDialog(BuildContext context, UserModel user,
      MeetModel meet, GangModel currentGang) async {
    final placesController = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Arrive with car!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: placesController,
              decoration:
                  InputDecoration(hintText: 'how many extra places you have?'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            RaisedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await showDialog(
                    context: context,
                    builder: (ctx) {
                      addCar(
                        context,
                        int.parse(placesController.text),
                      ).then((_) => Navigator.of(ctx).pop());

                      return AlertDialog(
                        content: Row(
                          children: [
                            CircularProgressIndicator(),
                          ],
                        ),
                      );
                    });
              },
              child: Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUserConfirmedArrival(BuildContext context) {
    final _currentGang = Provider.of<GangModel>(context, listen: false);
    final _currentUser = Provider.of<UserModel>(context, listen: false);
    final _meet = Provider.of<MeetModel>(context, listen: false);

    final EventMember eventMember = _meet.eventMemberById(_currentUser.uid);

    return Row(
      children: [
        if (eventMember.isComming == ConfirmationType.Arrive)
          OutlinedButton(
              child: Icon(
                eventMember.carRide != null
                    ? Icons.hail
                    : Icons.directions_car_outlined,
                color: eventMember.carRide != null
                    ? Colors.green
                    : eventMember.car == null
                        ? Colors.red
                        : Colors.green,
              ),
              onPressed: () async {
                if (eventMember.carRide != null) {
                  showModalBottomSheet(
                    context: context,
                    builder: (ctx) => CarOwnerControllers(_currentGang, _meet,
                        isDriver: false),
                  );
                } else if (eventMember.car == null) {
                  await addCarDialog(
                      context, _currentUser, _meet, _currentGang);
                } else {
                  showModalBottomSheet(
                    context: context,
                    builder: (ctx) => CarOwnerControllers(_currentGang, _meet),
                  );
                }
              }),
        SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              if (eventMember.isComming == ConfirmationType.Arrive)
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
              eventMember.isComming == ConfirmationType.Arrive
                  ? 'You are comming!\nclick to change'
                  : 'You are\'t comming!\nclick to change',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: eventMember.isComming == ConfirmationType.Arrive
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
