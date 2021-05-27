import 'package:flutter/material.dart';
import 'package:gangbook/models/post.dart';
import 'package:gangbook/utils/names_initials.dart';
import 'package:intl/intl.dart';

class LikesFeed extends StatelessWidget {
  final List<PostLike> likes;

  LikesFeed(this.likes);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: ListView.builder(
        itemCount: likes.length,
        itemBuilder: (_, i) => ListTile(
          leading: CircleAvatar(
            radius: 30,
            child: Text(NameInitials().getInitials(likes[i].name)),
          ),
          title: Text(likes[i].name),
          trailing: Text(
            DateFormat('dd/MM/yy \n HH:mm').format(likes[i].createdAt.toDate()),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
