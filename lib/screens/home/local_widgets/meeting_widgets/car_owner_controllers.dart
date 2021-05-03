import 'package:flutter/material.dart';
import 'package:gangbook/services/database.dart';
import 'package:gangbook/state_managment/current_gang.dart';
import 'package:gangbook/state_managment/current_user.dart';
import 'package:provider/provider.dart';

class CarOwnerControllers extends StatefulWidget {
  final CurrentGang currentGang;

  CarOwnerControllers(this.currentGang);

  @override
  _CarOwnerControllersState createState() => _CarOwnerControllersState();
}

class _CarOwnerControllersState extends State<CarOwnerControllers> {
  @override
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<CurrentUser>(context, listen: false);
    final car = widget.currentGang.eventMemberById(_currentUser.user.uid).car;

    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Your car',
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(height: 10),
          Text('extra places: ${car.places}'),
          ...car.riders
              .map(
                (rider) => ListTile(
                  title: Text(rider.name),
                  subtitle: Text(rider.pickupFrom ?? ''),
                  trailing: OutlinedButton(
                      style: ButtonStyle(
                        side: MaterialStateProperty.all<BorderSide>(
                            BorderSide(color: Colors.red.withOpacity(0.5))),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                      ),
                      onPressed: () async {
                        await AppDB().removeCarRider(
                          car: car,
                          gangId: widget.currentGang.gang.id,
                          meet: widget.currentGang.meet,
                          riderUid: rider.uid,
                        );

                        await widget.currentGang
                            .updateStateFromDB(widget.currentGang.gang.id);
                        setState(() {});
                      },
                      child: Text(
                        'remove',
                      )),
                ),
              )
              .toList(),
          Spacer(),
          OutlinedButton(
              style: ButtonStyle(
                side: MaterialStateProperty.all<BorderSide>(
                    BorderSide(color: Colors.red.withOpacity(0.5))),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              onPressed: () async {
                await AppDB().removeCar(
                  car: car,
                  gangId: widget.currentGang.gang.id,
                  meet: widget.currentGang.meet,
                );
                await widget.currentGang
                    .updateStateFromDB(widget.currentGang.gang.id);
                Navigator.of(context).pop();
              },
              child: Text(
                'remove car',
              )),
        ],
      ),
    );
  }
}
