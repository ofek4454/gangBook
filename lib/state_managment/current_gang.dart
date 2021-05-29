import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gangbook/models/app_gang.dart';
import 'package:gangbook/models/app_user.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/models/meet.dart';
import 'package:gangbook/models/post.dart';
import 'package:gangbook/services/database.dart';

class CurrentGang extends ChangeNotifier {
  AppGang _gang = AppGang();
  List<Meet> _meets = [];

  AppGang get gang => _gang;
  Meet getMeetById(String meetId) {
    return _meets.firstWhere((meet) => meet.id == meetId);
  }

  Future<void> updateStateFromDB(String gangId) async {
    try {
      _gang = await AppDB().getGangInfoById(gangId);
      _meets.clear();
      if (_gang.meetIds != null && _gang.meetIds.isNotEmpty) {
        for (String meetId in _gang.meetIds) {
          final meet = await AppDB().getMeetById(gangId, meetId);
          _meets.add(meet);
        }
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void addPost(Post post) {
    _gang.posts.insert(0, post);
    notifyListeners();
  }

  void likePost(Post post, String uid, String name) async {
    final postLike = PostLike(
      uid: uid,
      name: name,
      createdAt: Timestamp.now(),
    );
    post.likes.add(postLike);
    notifyListeners();
    final res = await AppDB().likePost(_gang.id, post.id, postLike);
    if (res == 'error') {
      post.likes.remove(postLike);
      notifyListeners();
    }
  }

  void likeComment(
      Post post, PostComment comment, String uid, String name) async {
    final postLike = PostLike(
      uid: uid,
      name: name,
      createdAt: Timestamp.now(),
    );
    comment.likes.add(postLike);
    notifyListeners();
    final res = await AppDB().likeComment(_gang.id, post.id, comment, postLike);
    if (res == 'error') {
      post.likes.remove(postLike);
      notifyListeners();
    }
  }

  void commentsOnPost(
      Post post, String uid, String name, String comment) async {
    final postComment = PostComment(
      uid: uid,
      name: name,
      comment: comment,
      createdAt: Timestamp.now(),
    );
    post.comments.add(postComment);
    notifyListeners();
    final res = await AppDB().commentOnPost(_gang.id, post.id, postComment);
    if (res == 'error') {
      post.comments.remove(postComment);
      notifyListeners();
    }
  }

  void unLikePost(Post post, String uid) async {
    final likeToRemove = post.likes.firstWhere((like) => like.uid == uid);
    post.likes.remove(likeToRemove);
    notifyListeners();
    final res = await AppDB().unLikePost(_gang.id, post.id, likeToRemove);
    if (res == 'error') {
      post.likes.add(likeToRemove);
      notifyListeners();
    }
  }

  void unLikeComment(Post post, PostComment comment, String uid) async {
    final likeToRemove = comment.likes.firstWhere((like) => like.uid == uid);
    comment.likes.remove(likeToRemove);
    notifyListeners();
    final res =
        await AppDB().unLikeComment(_gang.id, post.id, comment, likeToRemove);
    if (res == 'error') {
      post.likes.add(likeToRemove);
      notifyListeners();
    }
  }

  Future<String> removeCar(Car car, String meetId) async {
    final meet = getMeetById(meetId);
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

    final eventMember = eventMemberById(car.ownerId, meetId);
    eventMember.car = null;
    notifyListeners();

    return await AppDB().updateMeeting(gangId: _gang.id, meet: meet);
  }

  Future<void> meetAcception(
      {ConfirmationType isComming, String userId, String meetId}) async {
    final eventMember = eventMemberById(userId, meetId);
    final lastConfirmationType = eventMember.isComming;
    eventMember.isComming = isComming;
    if (isComming == ConfirmationType.NotArrive && eventMember.car != null) {
      removeCar(eventMember.car, meetId);
      eventMember.car = null;
    }

    notifyListeners();
    await AppDB().updateMeeting(
      gangId: _gang.id,
      meet: getMeetById(meetId),
    );
  }

  Future<void> confirmCarRideRequest(
    String riderUid,
    Meet meet,
    Car car,
    String pickUpFrom,
  ) async {
    final requstList = meet.membersAreComming
        .firstWhere((eventMember) => eventMember.uid == car.ownerId)
        .car
        .requests;

    final ridersList = meet.membersAreComming
        .firstWhere((eventMember) => eventMember.uid == car.ownerId)
        .car
        .riders;

    final index = requstList.indexWhere((rider) => rider.uid == riderUid);

    final rider = requstList.elementAt(index);

    requstList.removeAt(index);

    ridersList.add(rider);

    final riderEventMember = meet.membersAreComming
        .firstWhere((eventMember) => eventMember.uid == riderUid);

    riderEventMember.carRequests.remove(car.ownerId);
    riderEventMember.carRequests?.forEach((carOwnerId) {
      meet.membersAreComming
          .firstWhere((eventMember) => eventMember.uid == carOwnerId)
          .car
          .requests
          .removeWhere((carRider) => carRider.uid == riderEventMember.uid);
    });

    riderEventMember.carRequests.clear();
    riderEventMember.carRide = car.ownerId;
    notifyListeners();

    await AppDB().updateMeeting(gangId: _gang.id, meet: meet);
  }

  Future<void> addCar({int places, String userId, String meetId}) async {
    final meet = getMeetById(meetId);
    final eventMember = eventMemberById(userId, meetId);
    eventMember.car = Car(
      ownerId: userId,
      riders: [],
      places: places,
      requests: [],
    );

    eventMember.carRequests.clear();

    await AppDB().updateMeeting(gangId: _gang.id, meet: meet);
    notifyListeners();
  }

  Future<void> joinToCar(
      String meetId, AppUser user, String pickUpFrom, Car car) async {
    final meet = getMeetById(meetId);
    meet.membersAreComming
        .firstWhere((eventMember) => eventMember.uid == car.ownerId)
        .car
        .requests
        .add(CarRider(
          name: user.fullName,
          uid: user.uid,
          pickupFrom: pickUpFrom,
        ));
    meet.membersAreComming
        .firstWhere((eventMember) => eventMember.uid == user.uid)
        .carRequests
        .add(car.ownerId);
    notifyListeners();
    await AppDB().updateMeeting(gangId: _gang.id, meet: meet);
  }

  Future<void> removeCarRider(String meetId, Car car, String riderUid) async {
    final meet = getMeetById(meetId);
    final ridersList = car.riders;

    ridersList.removeWhere((rider) => rider.uid == riderUid);

    final riderEventMember = meet.membersAreComming
        .firstWhere((eventMember) => eventMember.uid == riderUid);

    riderEventMember.carRide = null;
    notifyListeners();
    await AppDB().updateMeeting(gangId: _gang.id, meet: meet);
  }

  Future<void> leaveGang(AppUser user) async {
    for (final meet in _meets) {
      final eventMember = eventMemberById(user.uid, meet.id);
      if (eventMember.car != null) {
        removeCar(eventMember.car, meet.id);
      }
      eventMember.carRequests.forEach((ownerId) {
        meet.membersAreComming
            .firstWhere((member) => member.uid == ownerId)
            .carRequests
            .removeWhere((riderId) => riderId == user.uid);
      });
      if (eventMember.carRide != null) {
        meet.membersAreComming
            .firstWhere((member) => member.uid == eventMember.carRide)
            .car
            .riders
            .removeWhere((rider) => rider.uid == user.uid);
      }
      meet.membersAreComming.removeWhere((member) => member.uid == user.uid);
      await AppDB().updateMeeting(gangId: _gang.id, meet: meet);
    }
    await AppDB().leaveGang(gangId: _gang.id, user: user);
  }

  EventMember eventMemberById(String uid, String meetId) {
    final meet = getMeetById(meetId);
    final EventMember eventMember =
        meet.membersAreComming.firstWhere((member) => member.uid == uid);
    return eventMember;
  }
}
