import 'package:flutter/material.dart';
import 'package:gangbook/models/post_model.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/screens/another_user_profile/another_user_profile_screen.dart';
import 'package:gangbook/screens/profile/profile_screen.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:gangbook/state_managment/user_state.dart';
import 'package:gangbook/utils/names_initials.dart';
import 'package:gangbook/widgets/user_image_bubble.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LikesFeed extends StatelessWidget {
  final List<PostLike> likes;

  LikesFeed(this.likes);

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: ListView.builder(
        itemCount: likes.length,
        itemBuilder: (_, i) => ListTile(
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
                  child: likes[i].uid == userState.user.uid
                      ? ProfileScreen(null)
                      : AnotherUserProfile(uid: likes[i].uid),
                ),
              ),
            );
          },
          leading: UserImagebubble(
            uid: likes[i].uid,
            radius: 30,
            userImageUrl: null,
            userName: likes[i].name,
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
