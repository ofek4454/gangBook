import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/services/database.dart';
import 'package:gangbook/state_managment/current_gang.dart';
import 'package:gangbook/state_managment/current_user.dart';
import 'package:provider/provider.dart';

class EvetMembersArrivingList extends StatelessWidget {
  Widget _buildNameRow(EventMember member, Color textColor,
      [BuildContext context]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            member.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
            ),
          ),
          if (member.car != null) _buildCar(member.car, context)
        ],
      ),
    );
  }

  Widget _buildCar(Car car, BuildContext context) {
    final currentUser = Provider.of<CurrentUser>(context, listen: false);
    final _currentGang = Provider.of<CurrentGang>(context, listen: false);

    Color color = Colors.green;
    if (car.places - 1 == car.riders.length)
      color = Colors.red;
    else if (car.places - car.riders.length <= 1) color = Colors.orange;
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: OutlinedButton(
        onPressed: () {
          if (car.places - 1 == car.riders.length) {
            // car is full
            Fluttertoast.showToast(
              msg: "This car is full",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          } else {
            if (car.ownerId == currentUser.user.uid) {
              Fluttertoast.showToast(
                msg: "You are the driver!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              return;
            }
            if (car.riders.contains(currentUser.user.uid)) {
              Fluttertoast.showToast(
                msg: "You are allredy in this car!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              return;
            }
            if (_currentGang.meet.membersAreComming
                    .firstWhere((em) => em.uid == currentUser.user.uid)
                    .car !=
                null) {
              Fluttertoast.showToast(
                msg: "You are placed in another car!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              return;
            }
            AppDB()
                .joinToCar(
                    user: currentUser.user, meet: _currentGang.meet, car: car)
                .then((value) {
              Fluttertoast.showToast(
                msg: "Joined successfully!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }).onError((error, stackTrace) {
              Fluttertoast.showToast(
                msg: "something went wrong, pleaes try again.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            });
          }
        },
        child: Icon(
          Icons.directions_car_outlined,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _currentGang = Provider.of<CurrentGang>(context, listen: false);

    final List<EventMember> arriving = [];
    final List<EventMember> notArriving = [];
    final List<EventMember> hasntConfirmed = [];

    _currentGang.meet.membersAreComming.forEach((em) {
      switch (em.isComming) {
        case ConfirmationType.Arrive:
          arriving.add(em);
          break;
        case ConfirmationType.NotArrive:
          notArriving.add(em);
          break;
        case ConfirmationType.HasntConfirmed:
          hasntConfirmed.add(em);
          break;
        default:
      }
    });

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: ListView(children: [
        ...arriving.map((em) => _buildNameRow(em, Colors.green, context)),
        if (notArriving.isNotEmpty) Divider(thickness: 1),
        ...notArriving.map((em) => _buildNameRow(em, Colors.red)),
        if (hasntConfirmed.isNotEmpty) Divider(thickness: 1),
        ...hasntConfirmed.map((em) => _buildNameRow(em, Colors.orange)),
      ]),
    );
  }
}