import 'package:flutter/material.dart';
import 'package:gangbook/models/gang_member.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:gangbook/state_managment/user_state.dart';
import 'package:gangbook/widgets/user_image_bubble.dart';
import 'package:provider/provider.dart';

class GangMemberTile extends StatelessWidget {
  final GangMember member;

  const GangMemberTile(this.member, {Key key}) : super(key: key);

  void kikOut(BuildContext context) async {
    final decideToKik = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('This action cannot be undone'),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Kik member'),
            textColor: Colors.red,
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('cancel'),
            textColor: Colors.black,
          ),
        ],
      ),
    );
    if (decideToKik)
      showDialog(
        context: context,
        builder: (ctx) {
          final gang = Provider.of<GangState>(context, listen: false);

          gang.kikOutFromGang(member).then((value) {
            Navigator.of(ctx).pop();
          });
          return AlertDialog(
              content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator.adaptive()],
          ));
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    final gangState = Provider.of<GangState>(context, listen: false);
    final userState = Provider.of<UserState>(context, listen: false);
    final Color leaderSignColor = Colors.green;

    return ListTile(
      leading: UserImagebubble(
        uid: member.uid,
        radius: 30,
        userImageUrl: null,
        userName: member.name,
      ),
      title: Text(
        member.name,
        style: Theme.of(context).textTheme.headline6,
      ),
      trailing: gangState.gang.leader == member.uid
          ? Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: leaderSignColor,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.stars,
                    color: leaderSignColor,
                  ),
                  Text(
                    'leader',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(color: leaderSignColor),
                  ),
                ],
              ),
            )
          : gangState.gang.leader == userState.user.uid
              ? ElevatedButton(
                  onPressed: () => kikOut(context),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.transparent),
                    elevation: MaterialStateProperty.all<double>(0),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  child: Text(
                    'Kik out',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(color: Colors.red),
                  ),
                )
              : null,
    );
  }
}
