import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/models/meet_model.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/services/meets_db.dart';

class MeetState {
  MeetModel _meet;
  String gangId;

  MeetState(this._meet, this.gangId);

  MeetModel get meet => _meet;

  EventMember eventMemberById(String uid) {
    final EventMember eventMember =
        _meet.membersAreComming.firstWhere((member) => member.uid == uid);
    return eventMember;
  }

  Future<String> removeCar(Car car) async {
    car.requests.forEach((rider) {
      _meet.membersAreComming.forEach((member) {
        if (rider.uid == member.uid) member.carRequests.remove(car.ownerId);
      });
    });

    car.riders.forEach((rider) {
      _meet.membersAreComming.forEach((member) {
        if (rider.uid == member.uid) member.carRide = null;
      });
    });

    final eventMember = eventMemberById(car.ownerId);
    eventMember.car = null;

    return await MeetDB().updateMeeting(gangId: gangId, meet: meet);
  }

  Future<void> meetAcception(
      {ConfirmationType isComming, String userId}) async {
    final eventMember = eventMemberById(userId);
    eventMember.isComming = isComming;
    if (isComming == ConfirmationType.NotArrive && eventMember.car != null) {
      removeCar(eventMember.car);
      eventMember.car = null;
    }

    await MeetDB().updateMeeting(gangId: gangId, meet: _meet);
  }

  Future<void> confirmCarRideRequest(
    String riderUid,
    Car car,
    String pickUpFrom,
  ) async {
    final requstList = car.requests;

    final ridersList = car.riders;

    final index = requstList.indexWhere((rider) => rider.uid == riderUid);

    final rider = requstList.elementAt(index);

    requstList.removeAt(index);

    ridersList.add(rider);

    final riderEventMember = eventMemberById(riderUid);

    riderEventMember.carRequests.remove(car.ownerId);
    riderEventMember.carRequests?.forEach((carOwnerId) {
      eventMemberById(carOwnerId)
          .car
          .requests
          .removeWhere((carRider) => carRider.uid == riderEventMember.uid);
    });

    riderEventMember.carRequests.clear();
    riderEventMember.carRide = car.ownerId;

    await MeetDB().updateMeeting(gangId: gangId, meet: _meet);
  }

  Future<void> addCar(int places, String userId) async {
    final eventMember = eventMemberById(userId);
    eventMember.car = Car(
      ownerId: userId,
      riders: [],
      places: places,
      requests: [],
    );
    //TODO remove request from all requasted cars
    eventMember.carRequests.clear();

    await MeetDB().updateMeeting(gangId: gangId, meet: _meet);
  }

  Future<void> joinToCar(UserModel user, String pickUpFrom, Car car) async {
    eventMemberById(car.ownerId).car.requests.add(CarRider(
          name: user.fullName,
          uid: user.uid,
          pickupFrom: pickUpFrom,
        ));
    eventMemberById(user.uid).carRequests.add(car.ownerId);
    await MeetDB().updateMeeting(gangId: gangId, meet: _meet);
  }

  Future<void> removeCarRider(Car car, String riderUid) async {
    final ridersList = car.riders;

    ridersList.removeWhere((rider) => rider.uid == riderUid);

    final riderEventMember = meet.membersAreComming
        .firstWhere((eventMember) => eventMember.uid == riderUid);

    riderEventMember.carRide = null;
    await MeetDB().updateMeeting(gangId: gangId, meet: _meet);
  }

  Future<void> removeEventMember(String uid) async {
    final eventMember = eventMemberById(uid);

    eventMember.carRequests.forEach((ownerId) {
      meet.membersAreComming
          .firstWhere((member) => member.uid == ownerId)
          .carRequests
          .removeWhere((riderId) => riderId == uid);
    });
    if (eventMember.carRide != null) {
      meet.membersAreComming
          .firstWhere((member) => member.uid == eventMember.carRide)
          .car
          .riders
          .removeWhere((rider) => rider.uid == uid);
    }
    meet.membersAreComming.removeWhere((member) => member.uid == uid);
    if (eventMember.car != null) {
      await removeCar(eventMember.car);
    } else {
      await MeetDB().updateMeeting(gangId: gangId, meet: _meet);
    }
  }
}
