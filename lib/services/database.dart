import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gangbook/models/app_gang.dart';
import 'package:gangbook/models/app_user.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/models/gang_member.dart';
import 'package:gangbook/models/meet.dart';
import 'package:gangbook/models/post.dart';

class AppDB {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<String> createUser(AppUser user) async {
    String retVal = 'error';
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'fullname': user.fullName,
        'email': user.email,
        'createdAt': Timestamp.now(),
      });
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<AppUser> getUserInfoByUid(String uid) async {
    AppUser _user = AppUser();

    try {
      DocumentSnapshot _doc =
          await _firestore.collection('users').doc(uid).get();
      _user.uid = uid;
      _user.fullName = _doc.data()['fullname'];
      _user.email = _doc.data()['email'];
      _user.createdAt = _doc.data()['createdAt'];
      _user.gangId = _doc.data()['gangId'];
    } catch (e) {
      print(e);
      return null;
    }
    return _user;
  }

  Future<String> createGang(String gangName, AppUser user) async {
    String retVal = 'error';
    List<String> members = [];

    try {
      members.add(GangMember(user.uid, user.fullName).toJson());
      final _docRef = await _firestore.collection('gangs').add({
        'name': gangName,
        'leader': user.uid,
        'members': members,
        'createdAt': Timestamp.now(),
        'meetIds': [],
      });
      await _firestore.collection('users').doc(user.uid).update({
        'gangId': _docRef.id,
      });
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> joinGang(String gangId, AppUser user) async {
    String retVal = 'error';
    List<String> members = [];
    try {
      members.add(GangMember(user.uid, user.fullName).toJson());
      await _firestore.collection('gangs').doc(gangId).update({
        'members': FieldValue.arrayUnion(members),
      });
      await _firestore.collection('users').doc(user.uid).update({
        'gangId': gangId,
      });
      final gangData = await _firestore.collection('gangs').doc(gangId).get();
      final List<dynamic> meetIds = gangData.data()['meetIds'] ?? [];
      if (meetIds.isNotEmpty) {
        for (String meetId in meetIds) {
          await _firestore
              .collection('gangs')
              .doc(gangId)
              .collection('meets')
              .doc(meetId)
              .update({
            'membersAreComming': FieldValue.arrayUnion(
              [
                EventMember(
                  uid: user.uid,
                  name: user.fullName,
                  isComming: ConfirmationType.HasntConfirmed,
                  car: null,
                  carRequests: [],
                  carRide: null,
                ).toJson(),
              ],
            ),
          });
        }
      }
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<AppGang> getGangInfoById(String gangId) async {
    AppGang _gang = AppGang();
    final List<GangMember> members = [];

    try {
      DocumentSnapshot _doc =
          await _firestore.collection('gangs').doc(gangId).get();
      final List<dynamic> membersData = _doc.data()['members'];
      membersData.forEach((data) {
        members.add(GangMember.fromJson(data));
      });

      _gang.id = gangId;
      _gang.name = _doc.data()['name'];
      _gang.leader = _doc.data()['leader'];
      _gang.createdAt = _doc.data()['createdAt'];
      _gang.members = members;
      _gang.meetIds = List<String>.from(_doc.data()['meetIds']) ?? [];
      _gang.posts = await loadPosts(gangId);
    } catch (e) {
      print(e);
      return null;
    }
    return _gang;
  }

  Future<Meet> getMeetById(String gangId, String meetId) async {
    Meet _meet = Meet();
    List<EventMember> eventMembers = [];

    try {
      DocumentSnapshot _doc = await _firestore
          .collection('gangs')
          .doc(gangId)
          .collection('meets')
          .doc(meetId)
          .get();
      final List<dynamic> membersData = _doc.data()['membersAreComming'];
      membersData.forEach((data) {
        eventMembers.add(EventMember.fromJson(data));
      });
      _meet.id = meetId;
      _meet.title = _doc.data()['title'];
      _meet.location = _doc.data()['location'];
      _meet.moreInfo = _doc.data()['moreInfo'];
      _meet.meetingAt = _doc.data()['meetingAt'];
      _meet.createdAt = _doc.data()['createdAt'];
      _meet.membersAreComming = eventMembers;
    } catch (e) {
      print(e);
      return null;
    }
    return _meet;
  }

  Future<String> setNewMeet({
    @required String title,
    @required String location,
    @required String moreInfo,
    @required Timestamp meetingAt,
    @required AppUser user,
  }) async {
    String retVal = 'error';
    List<String> membersAreComming = [];
    try {
      final gang = await getGangInfoById(user.gangId);
      final json = EventMember(
        uid: user.uid,
        name: user.fullName,
        isComming: ConfirmationType.Arrive,
        car: null,
        carRequests: [],
        carRide: null,
      ).toJson();

      membersAreComming.add(json);
      gang.members.forEach((gangMember) {
        if (gangMember.uid != user.uid) {
          membersAreComming.add(
            EventMember(
              uid: gangMember.uid,
              name: gangMember.name,
              isComming: ConfirmationType.HasntConfirmed,
              car: null,
              carRequests: [],
              carRide: null,
            ).toJson(),
          );
        }
      });
      DocumentReference _docRef = await _firestore
          .collection('gangs')
          .doc(user.gangId)
          .collection('meets')
          .add({
        'title': title,
        'location': location,
        'moreInfo': moreInfo,
        'meetingAt': meetingAt,
        'membersAreComming': membersAreComming,
        'createdAt': Timestamp.now(),
      });

      await _firestore.collection('gangs').doc(user.gangId).update({
        'meetIds': FieldValue.arrayUnion([_docRef.id])
      });

      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> meetAcception(
      {ConfirmationType isComming, AppUser user, Meet meet}) async {
    String retVal = 'error';
    meet.membersAreComming
        .firstWhere((eventMember) => eventMember.uid == user.uid)
        .isComming = isComming;
    final List<String> membersAreCommingJson = [];
    meet.membersAreComming.forEach((eventMember) {
      membersAreCommingJson.add(eventMember.toJson());
    });
    try {
      await _firestore
          .collection('gangs')
          .doc(user.gangId)
          .collection('meets')
          .doc(meet.id)
          .update({
        'membersAreComming': membersAreCommingJson,
      });
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> addCar({String gangId, Meet meet}) async {
    String retVal = 'error';

    final List<String> membersAreCommingJson = [];
    meet.membersAreComming.forEach((eventMember) {
      membersAreCommingJson.add(eventMember.toJson());
    });
    try {
      await _firestore
          .collection('gangs')
          .doc(gangId)
          .collection('meets')
          .doc(meet.id)
          .update({
        'membersAreComming': membersAreCommingJson,
      });
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> joinToCar({
    AppUser user,
    Meet meet,
    Car car,
    String pickUpFrom,
  }) async {
    String retVal = 'error';
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
    final List<String> membersAreCommingJson = [];
    meet.membersAreComming.forEach((eventMember) {
      membersAreCommingJson.add(eventMember.toJson());
    });
    try {
      await _firestore
          .collection('gangs')
          .doc(user.gangId)
          .collection('meets')
          .doc(meet.id)
          .update({
        'membersAreComming': membersAreCommingJson,
      });
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> confirmRideRequest({
    String gangId,
    Meet meet,
  }) async {
    String retVal = 'error';

    final List<String> membersAreCommingJson = [];
    meet.membersAreComming.forEach((eventMember) {
      membersAreCommingJson.add(eventMember.toJson());
    });
    try {
      await _firestore
          .collection('gangs')
          .doc(gangId)
          .collection('meets')
          .doc(meet.id)
          .update({
        'membersAreComming': membersAreCommingJson,
      });
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<List<CarRider>> removeCarRider({
    String gangId,
    String riderUid,
    Meet meet,
    Car car,
  }) async {
    List<CarRider> retVal = null;

    final ridersList = car.riders;

    ridersList.removeWhere((rider) => rider.uid == riderUid);

    final riderEventMember = meet.membersAreComming
        .firstWhere((eventMember) => eventMember.uid == riderUid);

    riderEventMember.carRide = null;

    final List<String> membersAreCommingJson = [];
    meet.membersAreComming.forEach((eventMember) {
      membersAreCommingJson.add(eventMember.toJson());
    });
    try {
      await _firestore
          .collection('gangs')
          .doc(gangId)
          .collection('meets')
          .doc(meet.id)
          .update({
        'membersAreComming': membersAreCommingJson,
      });
      retVal = ridersList;
    } catch (e) {
      print(e);
    }
    return ridersList;
  }

  Future<String> removeCar({
    String gangId,
    Meet meet,
    Car car,
  }) async {
    String retVal = 'error';

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

    meet.membersAreComming
        .firstWhere((member) => member.uid == car.ownerId)
        .car = null;

    final List<String> membersAreCommingJson = [];
    meet.membersAreComming.forEach((eventMember) {
      membersAreCommingJson.add(eventMember.toJson());
    });
    try {
      await _firestore
          .collection('gangs')
          .doc(gangId)
          .collection('meets')
          .doc(meet.id)
          .update({
        'membersAreComming': membersAreCommingJson,
      });
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<Post> uploadPost(String gangId, String authorName, String authorId,
      String content, List<File> images, List<File> videos) async {
    Post retVal = null;
    List<String> _imagesUrls = [];
    List<String> _videosUrls = [];

    try {
      final now = Timestamp.now();
      final docRef = await _firestore
          .collection('gangs')
          .doc(gangId)
          .collection('posts')
          .add({
        'authorName': authorName,
        'authorId': authorId,
        'content': content,
        'images': [],
        'videos': [],
        'createdAt': now,
        'likes': [],
      });

      for (int i = 0; i < images.length; i++) {
        final imageLocation = _firebaseStorage
            .ref('gangs')
            .child(gangId)
            .child('posts')
            .child(docRef.id)
            .child('$i');
        await imageLocation.putFile(images[i]);
        _imagesUrls.add(await imageLocation.getDownloadURL());
      }

      for (int i = images.length; i < (images.length + videos.length); i++) {
        final videoLocation = _firebaseStorage
            .ref('gangs')
            .child(gangId)
            .child('posts')
            .child(docRef.id)
            .child('$i');
        await videoLocation.putFile(videos[i - images.length]);
        _videosUrls.add(await videoLocation.getDownloadURL());
      }

      await docRef.update({
        'images': _imagesUrls,
        'videos': _videosUrls,
      });

      retVal = Post(
        authorId: authorId,
        authorName: authorName,
        comments: [],
        content: content,
        createdAt: now,
        id: docRef.id,
        images: _imagesUrls,
        videos: _videosUrls,
        likes: [],
      );
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<List<Post>> loadPosts(String gangId, [String lastPostId]) async {
    List<Post> posts = [];

    try {
      final postsCollection = await _firestore
          .collection('gangs')
          .doc(gangId)
          .collection('posts')
          .orderBy('createdAt')
          .get();

      for (final docRef in postsCollection.docs) {
        final List<PostLike> likes = [];
        final List<String> likesData =
            List<String>.from(docRef.data()['likes']);
        for (String likeData in likesData) {
          likes.add(PostLike.fromJson(likeData));
        }

        final List<PostComment> comments = [];
        final commetsCollection =
            await docRef.reference.collection('comments').get();
        for (final commentData in commetsCollection.docs) {
          List<PostLike> commentLikes = [];
          List<String> commentLikesData =
              List<String>.from(commentData.data()['likes']);
          comments.add(PostComment(
            commetId: commentData.id,
            comment: commentData.data()['comment'],
            uid: commentData.data()['uid'],
            likes: commentLikes,
            name: commentData.data()['name'],
            createdAt: commentData.data()['createdAt'],
          ));
        }

        posts.insert(
          0,
          Post(
            id: docRef.id,
            authorId: docRef.data()['authorId'],
            authorName: docRef.data()['authorName'],
            comments: comments,
            content: docRef.data()['content'],
            createdAt: docRef.data()['createdAt'],
            images: List<String>.from(docRef.data()['images']),
            videos: List<String>.from(docRef.data()['videos']),
            likes: likes,
          ),
        );
      }
    } catch (e) {
      print(e);
    }
    return posts;
  }

  Future<String> likePost(String gangId, String postId, PostLike like) async {
    String retVal = 'error';
    try {
      await _firestore
          .collection('gangs')
          .doc(gangId)
          .collection('posts')
          .doc(postId)
          .update({
        'likes': FieldValue.arrayUnion([like.toJson()]),
      });
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> commentOnPost(
      String gangId, String postId, PostComment comment) async {
    String retVal = 'error';
    try {
      final docRef = await _firestore
          .collection('gangs')
          .doc(gangId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
        'uid': comment.uid,
        'name': comment.name,
        'comment': comment.comment,
        'createdAt': comment.createdAt,
        'likes': [],
      });
      comment.commetId = docRef.id;
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> likeComment(
      String gangId, String postId, PostComment comment, PostLike like) async {
    String retVal = 'error';
    try {
      await _firestore
          .collection('gangs')
          .doc(gangId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(comment.commetId)
          .update({
        'likes': FieldValue.arrayUnion([like.toJson()])
      });
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> unLikeComment(
      String gangId, String postId, PostComment comment, PostLike like) async {
    String retVal = 'error';
    try {
      await _firestore
          .collection('gangs')
          .doc(gangId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(comment.commetId)
          .update({
        'likes': FieldValue.arrayRemove([like.toJson()])
      });
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> unLikePost(String gangId, String postId, PostLike like) async {
    String retVal = 'error';
    try {
      await _firestore
          .collection('gangs')
          .doc(gangId)
          .collection('posts')
          .doc(postId)
          .update({
        'likes': FieldValue.arrayRemove([like.toJson()]),
      });
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }
}
