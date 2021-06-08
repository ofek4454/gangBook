import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gangbook/models/auth_model.dart';
import 'package:gangbook/models/gang_model.dart';
import 'package:gangbook/models/post_model.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/services/posts_db.dart';
import 'package:gangbook/utils/names_initials.dart';
import 'package:intl/intl.dart';

class CommentsFeed extends StatelessWidget {
  final Post post;
  final GangModel currentGang;
  final UserModel user;

  CommentsFeed(this.post, this.currentGang, this.user);

  void likeComment(PostComment comment) async {
    final postLike = PostLike(
      uid: user.uid,
      name: user.fullName,
      createdAt: Timestamp.now(),
    );
    comment.likes.add(postLike);
    final res =
        await PostsDB().likeComment(currentGang.id, post.id, comment, postLike);
    if (res == 'error') {
      post.likes.remove(postLike);
    }
  }

  void unLikeComment(PostComment comment) async {
    final likeToRemove =
        comment.likes.firstWhere((like) => like.uid == user.uid);
    comment.likes.remove(likeToRemove);
    final res = await PostsDB()
        .unLikeComment(currentGang.id, post.id, comment, likeToRemove);
    if (res == 'error') {
      post.likes.add(likeToRemove);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<PostComment> comments = post.comments;

    return StatefulBuilder(
      builder: (context, setState) => Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: ListView.builder(
            itemCount: comments.length,
            itemBuilder: (ctx, i) {
              final bool doIlike = comments[i].doILike(user.uid);
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.profileImageUrl == null
                      ? null
                      : NetworkImage(user.profileImageUrl),
                  backgroundColor: Theme.of(context).canvasColor,
                  radius: 20,
                  child: user.profileImageUrl != null
                      ? null
                      : Text(
                          NameInitials().getInitials(user.fullName),
                          style: TextStyle(
                            color: Theme.of(context).secondaryHeaderColor,
                            fontSize: MediaQuery.of(context).size.width * 0.07,
                          ),
                        ),
                ),
                title: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: comments[i].name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: '  '),
                      TextSpan(
                        text: comments[i].comment,
                      ),
                    ],
                  ),
                ),
                subtitle: Text(
                  DateFormat('dd/MM/yy HH:mm')
                      .format(comments[i].createdAt.toDate()),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${comments[i].likes.length}',
                      style: TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: Icon(
                        doIlike ? Icons.favorite : Icons.favorite_border,
                      ),
                      color: doIlike ? Colors.red : Colors.black,
                      onPressed: () {
                        if (doIlike) {
                          setState(() {
                            unLikeComment(comments[i]);
                          });
                        } else {
                          setState(() {
                            likeComment(comments[i]);
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
