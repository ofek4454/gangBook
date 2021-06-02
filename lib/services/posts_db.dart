import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gangbook/models/post_model.dart';

class PostsDB {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

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
        final commetsCollection =
            await docRef.reference.collection('comments').get();
        final List<PostComment> comments = [];

        for (final commentData in commetsCollection.docs) {
          comments.add(PostComment.fromDocumentSnapshot(commentData));
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
            likes: List<String>.from(docRef.data()['likes'])
                .map<PostLike>((like) => PostLike.fromJson(like))
                .toList(),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
    return posts;
  }

  Future<Post> uploadPost(String gangId, String authorName, String authorId,
      String content, List<File> images, List<File> videos) async {
    Post retVal;
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
}