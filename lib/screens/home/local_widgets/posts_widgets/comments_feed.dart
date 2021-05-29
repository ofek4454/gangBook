import 'package:flutter/material.dart';
import 'package:gangbook/models/post.dart';
import 'package:gangbook/state_managment/current_gang.dart';
import 'package:gangbook/state_managment/current_user.dart';
import 'package:gangbook/utils/names_initials.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentsFeed extends StatelessWidget {
  final Post post;
  final CurrentGang currentGang;

  CommentsFeed(this.post, this.currentGang);

  @override
  Widget build(BuildContext context) {
    final List<PostComment> comments = post.comments;

    final user = Provider.of<CurrentUser>(context, listen: false).user;
    return StatefulBuilder(
      builder: (context, setState) => Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: ListView.builder(
            itemCount: comments.length,
            itemBuilder: (ctx, i) {
              final bool doIlike = comments[i].doILike(user.uid);
              return ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  child: Text(NameInitials().getInitials(comments[i].name)),
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
                //Text(comments[i].name),
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
                            currentGang.unLikeComment(
                                post, comments[i], user.uid);
                          });
                        } else {
                          setState(() {
                            currentGang.likeComment(
                                post, comments[i], user.uid, user.fullName);
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
