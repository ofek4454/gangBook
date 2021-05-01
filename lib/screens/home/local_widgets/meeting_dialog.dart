import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gangbook/models/app_user.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/models/meet.dart';
import 'package:gangbook/screens/schedule_new_meeting/schedule_new_meeting_screen.dart';
import 'package:gangbook/services/database.dart';
import 'package:gangbook/state_managment/current_gang.dart';
import 'package:gangbook/state_managment/current_user.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../widgets/whiteRoundedCard.dart';

class MeetingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentGang>(
      builder: (context, value, child) {
        if (value.meet != null) {
          return ThereIsMeet();
        } else {
          return ThereIsNoMeeting();
        }
      },
    );
  }
}

class ThereIsMeet extends StatelessWidget {
  const ThereIsMeet({
    Key key,
  }) : super(key: key);

  Future<void> _meetAcception(
      BuildContext context, ConfirmationType isCommig) async {
    final _currentUser = Provider.of<CurrentUser>(context, listen: false);
    final _currentGang = Provider.of<CurrentGang>(context, listen: false);

    final result = await AppDB().meetAcception(
      isComming: isCommig,
      user: _currentUser.user,
      meet: _currentGang.meet,
    );
    if (result == 'success') {
      _currentGang.updateStateFromDB(_currentGang.gang.id);
    }
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

  @override
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<CurrentUser>(context, listen: false);
    final _currentGang = Provider.of<CurrentGang>(context, listen: false);
    final userIsComming =
        _currentGang.meet.userAreComming(_currentUser.user.uid);
    print(_currentGang.meet.membersAreComming);

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
              userIsComming != ConfirmationType.HasntConfirmed
                  ? buildUserConfirmedArrival(context)
                  : buildUserHasntConfirmed(context),
              if (_currentGang.eventMemberById(_currentUser.user.uid).car !=
                  null)
                ..._buildApproveRider(
                  _currentGang.eventMemberById(_currentUser.user.uid),
                  _currentGang,
                ),
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
                      builder: (_) =>
                          EvetMembersArrivingList(currentGang: _currentGang),
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

  List<Widget> _buildApproveRider(
      EventMember eventMember, CurrentGang currentGang) {
    return eventMember.car.requests
        .map(
          (rider) => Row(
            children: [
              Text(rider.name),
              FlatButton(
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
                  child: Text('add'))
            ],
          ),
        )
        .toList();
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

  Widget buildUserConfirmedArrival(BuildContext context) {
    final _currentGang = Provider.of<CurrentGang>(context, listen: false);
    final _currentUser = Provider.of<CurrentUser>(context, listen: false);
    final EventMember eventMember =
        _currentGang.eventMemberById(_currentUser.user.uid);

    return Row(
      children: [
        OutlinedButton(
          child: Icon(
            Icons.directions_car_outlined,
            color: eventMember.car == null ? Colors.red : Colors.green,
          ),
          onPressed: () => eventMember.car != null
              ? null
              : addCar(context, _currentUser.user, _currentGang.meet).then(
                  (value) =>
                      _currentGang.updateStateFromDB(_currentUser.user.gangId)),
        ),
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

class EvetMembersArrivingList extends StatelessWidget {
  const EvetMembersArrivingList({
    Key key,
    @required CurrentGang currentGang,
  })  : _currentGang = currentGang,
        super(key: key);

  final CurrentGang _currentGang;

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
          if (member.car != null) _buildCar(member.car, _currentGang, context)
        ],
      ),
    );
  }

  Widget _buildCar(Car car, CurrentGang currentGang, BuildContext context) {
    final currentUser = Provider.of<CurrentUser>(context, listen: false);
    Color color = Colors.green;
    if (car.places - 1 == car.riders.length)
      color = Colors.red;
    else if (car.places - car.riders.length <= 2) color = Colors.orange;
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
            if (currentGang.meet.membersAreComming
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
                    user: currentUser.user, meet: currentGang.meet, car: car)
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

class ThereIsNoMeeting extends StatelessWidget {
  const ThereIsNoMeeting({
    Key key,
  }) : super(key: key);

  void _scheduleMeeting(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScheduleNewMeetingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WhiteRoundedCard(
      child: Column(
        children: [
          Text(
            'There is no meeting scheduled',
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).secondaryHeaderColor,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: RaisedButton(
                  onPressed: () => _scheduleMeeting(context),
                  child: Text(
                    'Schedule meeting',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
