import 'package:flutter/material.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/models/gang_model.dart';
import 'package:gangbook/models/meet_model.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/screens/home/local_widgets/meeting_widgets/car_owner_controllers.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:gangbook/state_managment/meet_state.dart';
import 'package:gangbook/state_managment/user_state.dart';
import 'package:provider/provider.dart';

class UserArrivalControlButtons extends StatelessWidget {
  final bool isChangeable;

  UserArrivalControlButtons({this.isChangeable});

  Future<void> _meetAcception(
      BuildContext context, ConfirmationType isComming) async {
    final _currentUser = Provider.of<UserState>(context, listen: false).user;
    final _meet = Provider.of<MeetState>(context, listen: false);

    await _meet.meetAcception(userId: _currentUser.uid, isComming: isComming);
  }

  @override
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<UserState>(context, listen: false).user;
    final _meet = Provider.of<MeetState>(context, listen: false);

    final userIsComming = _meet.meet.userAreComming(_currentUser.uid);

    return GestureDetector(
      onTap: () {
        if (!isChangeable)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You cannot change meets that passed.'),
              backgroundColor: Colors.red,
            ),
          );
      },
      child: AbsorbPointer(
        absorbing: !isChangeable,
        child: userIsComming != ConfirmationType.HasntConfirmed
            ? buildUserConfirmedArrival(context)
            : buildUserHasntConfirmed(context),
      ),
    );
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

  Future<void> addCarDialog(BuildContext context) async {
    final _currentUser = Provider.of<UserState>(context, listen: false).user;
    final _meet = Provider.of<MeetState>(context, listen: false);
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
                      _meet
                          .addCar(int.parse(placesController.text),
                              _currentUser.uid)
                          .then((_) => Navigator.of(ctx).pop());

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
    final _currentGang = Provider.of<GangState>(context, listen: false);
    final _currentUser = Provider.of<UserState>(context, listen: false).user;
    final _meet = Provider.of<MeetState>(context, listen: false);

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
                    builder: (ctx) => CarOwnerControllers(
                        _currentGang.gang, _meet,
                        isDriver: false),
                  );
                } else if (eventMember.car == null) {
                  await addCarDialog(context);
                } else {
                  showModalBottomSheet(
                    context: context,
                    builder: (ctx) =>
                        CarOwnerControllers(_currentGang.gang, _meet),
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
