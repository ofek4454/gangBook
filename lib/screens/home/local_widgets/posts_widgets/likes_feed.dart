import 'package:flutter/material.dart';
import 'package:gangbook/models/post_model.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/utils/names_initials.dart';
import 'package:intl/intl.dart';

class LikesFeed extends StatelessWidget {
  final List<PostLike> likes;
  final UserModel user;

  LikesFeed(this.likes, this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: ListView.builder(
        itemCount: likes.length,
        itemBuilder: (_, i) => ListTile(
          leading: CircleAvatar(
            backgroundImage: user.profileImageUrl == null
                ? null
                : NetworkImage(user.profileImageUrl),
            backgroundColor: Theme.of(context).canvasColor,
            radius: 30,
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
