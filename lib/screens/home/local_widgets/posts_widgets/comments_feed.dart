import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gangbook/models/post_model.dart';
import 'package:gangbook/screens/another_user_profile/another_user_profile_screen.dart';
import 'package:gangbook/screens/profile/profile_screen.dart';
import 'package:gangbook/services/posts_db.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:gangbook/state_managment/user_state.dart';
import 'package:gangbook/widgets/user_image_bubble.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentsFeed extends StatelessWidget {
  final Post post;

  CommentsFeed(this.post);

  void likeComment(PostComment comment, BuildContext context) async {
    final user = Provider.of<UserState>(context, listen: false).user;
    final gang = Provider.of<GangState>(context, listen: false).gang;

    final postLike = PostLike(
      uid: user.uid,
      name: user.fullName,
      createdAt: Timestamp.now(),
    );
    comment.likes.add(postLike);
    final res =
        await PostsDB().likeComment(gang.id, post.id, comment, postLike);
    if (res == 'error') {
      post.likes.remove(postLike);
    }
  }

  void unLikeComment(PostComment comment, BuildContext context) async {
    final user = Provider.of<UserState>(context, listen: false).user;
    final gang = Provider.of<GangState>(context, listen: false).gang;

    final likeToRemove =
        comment.likes.firstWhere((like) => like.uid == user.uid);
    comment.likes.remove(likeToRemove);
    final res =
        await PostsDB().unLikeComment(gang.id, post.id, comment, likeToRemove);
    if (res == 'error') {
      post.likes.add(likeToRemove);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context, listen: false);
    final List<PostComment> comments = post.comments;

    return StatefulBuilder(
      builder: (context, setState) => Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: ListView.builder(
            itemCount: comments.length,
            itemBuilder: (ctx, i) {
              final bool doIlike = comments[i].doILike(userState.user.uid);
              return ListTile(
                leading: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (navCtx) => MultiProvider(
                          providers: [
                            Provider<GangState>.value(
                              value: Provider.of<GangState>(context),
                            ),
                            Provider<UserState>.value(
                              value: Provider.of<UserState>(context),
                            ),
                          ],
                          child: comments[i].uid == userState.user.uid
                              ? ProfileScreen(null)
                              : AnotherUserProfile(uid: comments[i].uid),
                        ),
                      ),
                    );
                  },
                  child: UserImagebubble(
                    uid: comments[i].uid,
                    radius: 20,
                    userName: comments[i].name,
                    userImageUrl: null,
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
                            unLikeComment(comments[i], context);
                          });
                        } else {
                          setState(() {
                            likeComment(comments[i], context);
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
