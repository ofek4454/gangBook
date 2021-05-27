import 'package:flutter/material.dart';
import 'package:gangbook/models/post.dart';
import 'package:gangbook/utils/names_initials.dart';
import 'package:intl/intl.dart';

class CommentsFeed extends StatelessWidget {
  final List<PostComment> comments;

  CommentsFeed(this.comments);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: ListView.builder(
        itemCount: comments.length,
        itemBuilder: (_, i) => ListTile(
          leading: CircleAvatar(
            radius: 30,
            child: Text(NameInitials().getInitials(comments[i].name)),
          ),
          title: Text(comments[i].name),
          subtitle: Text(comments[i].comment),
          trailing: Text(
            DateFormat('dd/MM/yy \n HH:mm')
                .format(comments[i].createdAt.toDate()),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
