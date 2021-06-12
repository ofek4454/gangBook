import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gangbook/models/post_model.dart';
import 'package:gangbook/services/cloudinary_requests.dart';

class PostsDB {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Post>> loadAllPosts(String gangId, [String lastPostId]) async {
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
          Post.fromDocumentSnapshot(docRef, comments),
        );
      }
    } catch (e) {
      print(e);
    }
    return posts;
  }

  Future<List<Post>> loadUsersPosts(String gangId, String uid) async {
    List<Post> posts = [];

    try {
      final postsCollection = await _firestore
          .collection('gangs')
          .doc(gangId)
          .collection('posts')
          .where('authorId', isEqualTo: uid)
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
          Post.fromDocumentSnapshot(docRef, comments),
        );
      }
    } catch (e) {
      print(e);
    }
    return posts;
  }

  Future<List<Post>> loadSavedPosts(
      String gangId, String uid, List<String> savedPosts) async {
    List<Post> posts = [];

    try {
      final postsCollection = await _firestore
          .collection('gangs')
          .doc(gangId)
          .collection('posts')
          .get();

      for (final docRef in postsCollection.docs) {
        if (savedPosts.contains(docRef.id)) {
          final commetsCollection =
              await docRef.reference.collection('comments').get();
          final List<PostComment> comments = [];

          for (final commentData in commetsCollection.docs) {
            comments.add(PostComment.fromDocumentSnapshot(commentData));
          }

          posts.insert(
            0,
            Post.fromDocumentSnapshot(docRef, comments),
          );
        }
      }
    } catch (e) {
      print(e);
    }
    return posts;
  }

  Future<Post> uploadPost(
      String gangId,
      String authorName,
      String authorId,
      String content,
      List<File> images,
      List<File> videos,
      String authorImage) async {
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
        'authorImage': authorImage
      });

      for (int i = 0; i < images.length; i++) {
        final imageUrl = await CloudinaryRequests().uploadPhoto(
          gangId: gangId,
          postId: docRef.id,
          fileName: '$i',
          image: images[i],
        );
        _imagesUrls.add(imageUrl);
      }

      for (int i = images.length; i < (images.length + videos.length); i++) {
        final videoUrl = await CloudinaryRequests().uploadVideo(
          gangId: gangId,
          postId: docRef.id,
          fileName: '$i',
          video: videos[i],
        );
        _videosUrls.add(videoUrl);
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
        authorImage: authorImage,
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

  Future<String> deletePost(String gangId, String postId) async {
    String retVal = 'error';
    try {
      await _firestore
          .collection('gangs')
          .doc(gangId)
          .collection('posts')
          .doc(postId)
          .delete();
      retVal = 'success';
    } catch (e) {
      print(e);
    }
    return retVal;
  }
}
