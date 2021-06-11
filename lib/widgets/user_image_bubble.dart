import 'package:flutter/material.dart';
import 'package:gangbook/utils/names_initials.dart';

class UserImagebubble extends StatelessWidget {
  final String userName;
  final String userImageUrl;
  final double radius;
  const UserImagebubble(
      {Key key, this.userImageUrl, this.userName, this.radius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: userImageUrl == null ? null : NetworkImage(userImageUrl),
      backgroundColor: Theme.of(context).canvasColor,
      radius: radius ?? 20,
      child: userImageUrl != null
          ? null
          : Text(
              NameInitials().getInitials(userName),
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
                fontSize: MediaQuery.of(context).size.width * 0.07,
              ),
            ),
    );
  }
}
