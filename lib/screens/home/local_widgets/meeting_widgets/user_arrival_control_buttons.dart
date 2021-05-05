import 'package:flutter/material.dart';
import 'package:gangbook/models/app_user.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/models/meet.dart';
import 'package:gangbook/screens/home/local_widgets/meeting_widgets/car_owner_controllers.dart';
import 'package:gangbook/services/database.dart';
import 'package:gangbook/state_managment/current_gang.dart';
import 'package:gangbook/state_managment/current_user.dart';
import 'package:provider/provider.dart';

class UserArrivalControlButtons extends StatelessWidget {
  Future<void> _meetAcception(
      BuildContext context, ConfirmationType isCommig) async {
    final _currentUser = Provider.of<CurrentUser>(context, listen: false);
    final _currentGang = Provider.of<CurrentGang>(context, listen: false);
    final _meet = Provider.of<Meet>(context, listen: false);

    final result = await AppDB().meetAcception(
      isComming: isCommig,
      user: _currentUser.user,
      meet: _meet,
    );
    if (result == 'success') {
      _currentGang.updateStateFromDB(_currentGang.gang.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<CurrentUser>(context, listen: false);
    final _currentGang = Provider.of<CurrentGang>(context, listen: false);
    final _meet = Provider.of<Meet>(context, listen: false);

    final userIsComming = _meet.userAreComming(_currentUser.user.uid);

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

  Future<void> addCar(BuildContext context, AppUser user, Meet meet) async {
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
                      AppDB()
                          .addCar(
                            places: int.parse(placesController.text),
                            user: user,
                            meet: meet,
                          )
                          .then((value) => Navigator.of(ctx).pop());
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
    final _currentGang = Provider.of<CurrentGang>(context, listen: false);
    final _currentUser = Provider.of<CurrentUser>(context, listen: false);
    final _meet = Provider.of<Meet>(context, listen: false);

    final EventMember eventMember =
        _currentGang.eventMemberById(_currentUser.user.uid, _meet.id);

    return Row(
      children: [
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
            onPressed: () {
              if (eventMember.carRide != null) {
                showModalBottomSheet(
                  context: context,
                  builder: (ctx) =>
                      CarOwnerControllers(_currentGang, _meet, isDriver: false),
                );
              } else if (eventMember.car == null) {
                addCar(context, _currentUser.user, _meet).then(
                  (value) =>
                      _currentGang.updateStateFromDB(_currentUser.user.gangId),
                );
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
