import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gangbook/services/user_db.dart';
import 'package:gangbook/utils/names_initials.dart';

class UserImagebubble extends StatelessWidget {
  final String userName;
  final String userImageUrl;
  final String uid;
  final double radius;
  const UserImagebubble(
      {Key key,
      this.userImageUrl,
      this.userName,
      this.radius,
      @required this.uid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (userImageUrl != null) {
      return CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(userImageUrl),
        backgroundColor: Theme.of(context).canvasColor,
        radius: radius ?? 20,
      );
    } else {
      return FutureBuilder<Map<String, String>>(
        future: UserDB().getUserData(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return CircleAvatar(
              backgroundColor: Theme.of(context).canvasColor,
              radius: radius ?? 20,
              child: Text(
                NameInitials().getInitials(userName),
                style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontSize: MediaQuery.of(context).size.width * 0.07,
                ),
              ),
            );
          }
          return CircleAvatar(
            backgroundImage: snapshot.data['imageUrl'] == null
                ? null
                : CachedNetworkImageProvider(
                    snapshot.data['imageUrl'],
                  ),
            backgroundColor: HSLColor.fromColor(Theme.of(context).canvasColor)
                .withLightness(0.8)
                .toColor(),
            radius: radius ?? 20,
            child: snapshot.data['imageUrl'] != null
                ? null
                : Text(
                    NameInitials().getInitials(userName),
                    style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontSize: MediaQuery.of(context).size.width * 0.07,
                    ),
                  ),
          );
        },
      );
    }
  }
}
