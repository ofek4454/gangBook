import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/screens/gang_join_requests/gang_join_requests_screen.dart';
import 'package:gangbook/screens/home/home_screen.dart';
import 'package:gangbook/screens/invite_to_gang/invite_to_gang_screen.dart';
import 'package:gangbook/screens/meets_history/history_screen.dart';
import 'package:gangbook/screens/profile/profile_screen.dart';
import 'package:gangbook/services/auth.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:gangbook/state_managment/posts_feed.dart';
import 'package:gangbook/state_managment/user_state.dart';
import 'package:gangbook/utils/names_initials.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  Widget _currentPage;
  bool isOpen = false;
  Duration duration = Duration(milliseconds: 300);
  double value = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = ChangeNotifierProvider<PostsFeed>(
      create: (context) => PostsFeed(),
      child: HomeScreen(openDrawer),
    );
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final gang = Provider.of<GangState>(context, listen: false);
    if (gang != null && gang.gang != null) {
      FirebaseMessaging.instance.subscribeToTopic(gang.gang.id + "Meets");
      FirebaseMessaging.instance.subscribeToTopic(gang.gang.id + "Chat");

      FirebaseMessaging.onMessage.listen(
        (RemoteMessage message) {
          if (message.from.contains('Chat')) {
            //Do something
          } else if (message.from.contains('Meets')) {
            ScaffoldMessenger.of(_scaffoldkey.currentContext).showSnackBar(
              SnackBar(
                content: Text('new meet is schedulled! check in home page'),
              ),
            );
          }
        },
      );
    }
  }

  void openDrawer() {
    if (isOpen)
      setState(() {
        value = 0;
        isOpen = false;
      });
    else
      setState(() {
        value = 1;
        isOpen = true;
      });
  }

  void changePage(Widget pageToShow) {
    _currentPage = pageToShow;
    openDrawer();
  }

  Future<void> _signout() async {
    await Auth().signOut();
  }

  void _leaveGang(UserModel user) async {
    openDrawer();

    final decideToLeaveGang = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('This action cannot be undone'),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('leave gang'),
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
    if (decideToLeaveGang)
      showDialog(
        context: context,
        builder: (ctx) {
          final gang = Provider.of<GangState>(context, listen: false);

          gang.leaveGang(user).then((value) {
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
    final user = Provider.of<UserState>(context, listen: false).user;
    final gangState = Provider.of<GangState>(context, listen: false);

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w500,
    );
    return Scaffold(
      key: _scaffoldkey,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).hintColor,
                  Theme.of(context).secondaryHeaderColor,
                ],
                stops: [0, 0.7],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.23,
                    child: DrawerHeader(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundImage: user.profileImageUrl == null
                                ? null
                                : NetworkImage(user.profileImageUrl),
                            backgroundColor: Theme.of(context).canvasColor,
                            radius: MediaQuery.of(context).size.width * 0.1,
                            child: user.profileImageUrl != null
                                ? null
                                : Text(
                                    NameInitials().getInitials(user.fullName),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.07,
                                    ),
                                  ),
                          ),
                          //SizedBox(width: 15),
                          Text(
                            user.fullName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 30,
                            ),
                          ),
                          FittedBox(
                            child: Text(
                              '"${gangState?.gang?.name}"',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          onTap: () {
                            if (_currentPage.runtimeType is HomeScreen)
                              openDrawer();
                            else
                              changePage(
                                ChangeNotifierProvider<PostsFeed>(
                                  create: (context) => PostsFeed(),
                                  child: HomeScreen(openDrawer),
                                ),
                              );
                          },
                          leading: Icon(
                            Icons.home,
                            color: Colors.white,
                          ),
                          title: Text(
                            'Home',
                            style: textStyle,
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            if (_currentPage.runtimeType is HistoryScreen)
                              openDrawer();
                            else
                              changePage(HistoryScreen(openDrawer));
                          },
                          leading: Icon(
                            Icons.history,
                            color: Colors.white,
                          ),
                          title: Text(
                            'History',
                            style: textStyle,
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            if (_currentPage.runtimeType is ProfileScreen)
                              openDrawer();
                            else
                              changePage(
                                ProfileScreen(openDrawer),
                              );
                          },
                          leading: Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                          title: Text(
                            'Profile',
                            style: textStyle,
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            if (_currentPage.runtimeType is InviteToGangScreen)
                              openDrawer();
                            else
                              changePage(InviteToGangScreen(openDrawer));
                          },
                          leading: Icon(
                            Icons.share,
                            color: Colors.white,
                          ),
                          title: Text(
                            'Invite to gang',
                            style: textStyle,
                          ),
                        ),
                        ListTile(
                          onTap: () {},
                          leading: Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                          title: Text(
                            'Settings',
                            style: textStyle,
                          ),
                        ),
                        if (user.uid == gangState?.gang?.leader)
                          ListTile(
                            onTap: () {
                              if (_currentPage.runtimeType
                                  is GangJoinRequestsScreen)
                                openDrawer();
                              else
                                changePage(GangJoinRequestsScreen(openDrawer));
                            },
                            leading: Icon(
                              Icons.people,
                              color: Colors.white,
                            ),
                            title: Text(
                              'Join requests',
                              style: textStyle,
                            ),
                          ),
                        ListTile(
                          onTap: () => _leaveGang(user),
                          leading: Icon(
                            Icons.people_alt,
                            color: Colors.red,
                          ),
                          title: Text(
                            'Leave gang',
                            style: textStyle.copyWith(color: Colors.red),
                          ),
                        ),
                        ListTile(
                          onTap: () => _signout(),
                          leading: Icon(
                            Icons.exit_to_app,
                            color: Colors.red,
                          ),
                          title: Text(
                            'Log out',
                            style: textStyle.copyWith(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: value),
            duration: duration,
            curve: Curves.easeIn,
            builder: (_, double val, __) => Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..setEntry(0, 3, 200 * val)
                ..rotateY((pi / 6) * val),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.horizontal(left: Radius.circular(30 * val)),
                child: GestureDetector(
                    onTap: () => isOpen ? openDrawer() : null,
                    child: AbsorbPointer(
                      absorbing: isOpen,
                      child: AnimatedSwitcher(
                        duration: duration,
                        child: _currentPage,
                      ),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
