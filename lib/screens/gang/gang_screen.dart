import 'package:flutter/material.dart';
import 'package:gangbook/screens/another_user_profile/another_user_profile_screen.dart';
import 'package:gangbook/screens/gang/local_widgets/gang_image.dart';
import 'package:gangbook/screens/gang/local_widgets/gang_member_tile.dart';
import 'package:gangbook/screens/profile/local_widgets/profile_image_and_bg.dart';
import 'package:gangbook/screens/profile/profile_screen.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:gangbook/state_managment/user_state.dart';
import 'package:provider/provider.dart';

class GangScreen extends StatelessWidget {
  final Function openDrawer;
  const GangScreen(this.openDrawer, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final imageRaduis = screenSize.width * 0.25;
    final gangState = Provider.of<GangState>(context);
    final userState = Provider.of<UserState>(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, value) {
          return [
            SliverAppBar(
              expandedHeight: imageRaduis * 3.5,
              flexibleSpace: FlexibleSpaceBar(
                background: GangImage(imageRaduis),
              ),
              pinned: true,
              elevation: 0,
              title: Text(
                gangState.gang.name,
                style: TextStyle(color: Colors.white),
              ),
              centerTitle: true,
              leading: IconButton(
                color: Colors.white,
                icon: Icon(Icons.menu_rounded),
                onPressed: () => openDrawer(),
              ),
            ),
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final member = gangState.gang.members[index];
                  return InkWell(
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
                            child: member.uid == userState.user.uid
                                ? ProfileScreen(null)
                                : AnotherUserProfile(uid: member.uid),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Theme.of(context).hintColor),
                        ),
                      ),
                      child: GangMemberTile(member),
                    ),
                  );
                },
                childCount: gangState.gang.members.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
