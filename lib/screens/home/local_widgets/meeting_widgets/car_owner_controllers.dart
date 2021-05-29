import 'package:flutter/material.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/models/meet.dart';
import 'package:gangbook/services/database.dart';
import 'package:gangbook/state_managment/current_gang.dart';
import 'package:gangbook/state_managment/current_user.dart';
import 'package:provider/provider.dart';

class CarOwnerControllers extends StatefulWidget {
  final CurrentGang currentGang;
  final Meet meet;
  final bool isDriver;

  CarOwnerControllers(this.currentGang, this.meet, {this.isDriver = true});

  @override
  _CarOwnerControllersState createState() => _CarOwnerControllersState();
}

class _CarOwnerControllersState extends State<CarOwnerControllers> {
  @override
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<CurrentUser>(context, listen: false);

    EventMember carOwner;
    Car car;
    if (widget.isDriver) {
      car = widget.currentGang
          .eventMemberById(_currentUser.user.uid, widget.meet.id)
          .car;
    } else {
      final ev = widget.currentGang
          .eventMemberById(_currentUser.user.uid, widget.meet.id);
      carOwner = widget.currentGang.eventMemberById(ev.carRide, widget.meet.id);
      car = carOwner.car;
    }

    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            widget.isDriver ? 'Your car' : 'Your ride with ${carOwner.name}',
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(height: 10),
          Text('extra places: ${car.riders.length}/${car.places}'),
          ...car.riders
              .map(
                (rider) => Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black54,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text(rider.name),
                    subtitle: Text(rider.pickupFrom ?? ''),
                    trailing: !widget.isDriver
                        ? null
                        : OutlinedButton(
                            style: ButtonStyle(
                              side: MaterialStateProperty.all<BorderSide>(
                                  BorderSide(
                                      color: Colors.red.withOpacity(0.5))),
                              foregroundColor:
                                  MaterialStateProperty.all<Color>(Colors.red),
                            ),
                            onPressed: () async {
                              await widget.currentGang.removeCarRider(
                                widget.meet.id,
                                car,
                                rider.uid,
                              );
                            },
                            child: Text(
                              'remove',
                            )),
                  ),
                ),
              )
              .toList(),
          Spacer(),
          if (widget.isDriver)
            OutlinedButton(
                style: ButtonStyle(
                  side: MaterialStateProperty.all<BorderSide>(
                      BorderSide(color: Colors.red.withOpacity(0.5))),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
                onPressed: () async {
                  final desideToRemoveCar = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Are you sure?'),
                      content: Text('This action cannot be undone'),
                      actions: [
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text('remove car'),
                          textColor: Colors.red,
                        ),
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text('cancel'),
                          textColor: Colors.black,
                        ),
                      ],
                    ),
                  );
                  if (!desideToRemoveCar) return;
                  final result =
                      await widget.currentGang.removeCar(car, widget.meet.id);
                  if (result == 'success') {
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Something went wrong, please try again'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text(
                  'remove car',
                )),
        ],
      ),
    );
  }
}
