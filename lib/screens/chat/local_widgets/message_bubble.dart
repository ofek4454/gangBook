import 'package:flutter/material.dart';
import 'package:gangbook/models/auth_model.dart';
import 'package:gangbook/models/chat_model.dart';
import 'package:gangbook/screens/another_user_profile/another_user_profile_screen.dart';
import 'package:gangbook/screens/profile/profile_screen.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:gangbook/state_managment/user_state.dart';
import 'package:gangbook/widgets/user_image_bubble.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble(this.message, [Key key]) : super(key: key);

  bool isSendByMe(BuildContext context) {
    final uid = Provider.of<AuthModel>(context, listen: false).uid;
    return uid == message.sender.uid;
  }

  void goToUserProfileScreen(BuildContext context, String uid) {
    final userState = Provider.of<UserState>(context, listen: false);
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
          child: uid == userState.user.uid
              ? ProfileScreen(null)
              : AnotherUserProfile(uid: uid),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sendByMe = isSendByMe(context);
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              margin: EdgeInsets.all(screenWidth * 0.025),
              width: screenWidth * 0.6,
              decoration: BoxDecoration(
                color: sendByMe ? Colors.green : Theme.of(context).accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(sendByMe ? 15 : 0),
                  bottomRight: Radius.circular(sendByMe ? 0 : 15),
                ),
              ),
              child: Column(
                crossAxisAlignment: sendByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () =>
                        goToUserProfileScreen(context, message.sender.uid),
                    child: Text(
                      message.sender.name,
                      style: TextStyle(
                        color:
                            Theme.of(context).accentTextTheme.headline6.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SelectableText(
                    message.message,
                    style: TextStyle(
                      color: Theme.of(context).accentTextTheme.headline6.color,
                      fontSize: 18,
                    ),
                    textAlign: sendByMe ? TextAlign.end : TextAlign.start,
                  ),
                  Container(
                    width: double.infinity,
                    alignment:
                        sendByMe ? Alignment.bottomLeft : Alignment.bottomRight,
                    child: Text(
                      DateFormat('HH:mm').format(DateTime.parse(
                          message.createdAt.toDate().toString())),
                      style: TextStyle(
                        color:
                            Theme.of(context).accentTextTheme.headline6.color,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: sendByMe ? -screenWidth * 0.015 : null,
              right: !sendByMe ? -screenWidth * 0.015 : null,
              top: -screenWidth * 0.015,
              child: InkWell(
                onTap: () => goToUserProfileScreen(context, message.sender.uid),
                child: UserImagebubble(
                  uid: message.sender.uid,
                  userName: message.sender.name,
                  userImageUrl: message.sender.image,
                  radius: screenWidth * 0.05,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
