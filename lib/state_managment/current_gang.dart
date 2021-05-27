import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gangbook/models/app_gang.dart';
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

  void removeCar(Car car, String meetId) {
    final eventMember = eventMemberById(car.ownerId, meetId);
    eventMember.car = null;
    notifyListeners();
  }

  void meetAcception(
      {ConfirmationType isComming, String userId, String meetId}) {
    final eventMember = eventMemberById(userId, meetId);
    eventMember.isComming = isComming;
    notifyListeners();
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
    await AppDB().confirmRideRequest(gangId: _gang.id, meet: meet);
    notifyListeners();
  }

  Future<void> addCar({int places, String userId, String meetId}) async {
    final meet = getMeetById(meetId);
    meet.membersAreComming
        .firstWhere((eventMember) => eventMember.uid == userId)
        .car = Car(
      ownerId: userId,
      riders: [],
      places: places,
      requests: [],
    );
    await AppDB().addCar(gangId: _gang.id, meet: meet);
    notifyListeners();
  }

  EventMember eventMemberById(String uid, String meetId) {
    final meet = getMeetById(meetId);
    final EventMember eventMember =
        meet.membersAreComming.firstWhere((member) => member.uid == uid);
    return eventMember;
  }
}
