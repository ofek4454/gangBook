import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/screens/chat/chat_screen.dart';
import 'package:gangbook/screens/gang/gang_screen.dart';
import 'package:gangbook/screens/gang_join_requests/gang_join_requests_screen.dart';
import 'package:gangbook/screens/home/home_screen.dart';
import 'package:gangbook/screens/invite_to_gang/invite_to_gang_screen.dart';
import 'package:gangbook/screens/meets_history/history_screen.dart';
import 'package:gangbook/screens/profile/profile_screen.dart';
import 'package:gangbook/screens/settings/settings_screen.dart';
import 'package:gangbook/services/auth.dart';
import 'package:gangbook/services/database_streams.dart';
import 'package:gangbook/state_managment/chat_state.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:gangbook/state_managment/posts_feed.dart';
import 'package:gangbook/state_managment/user_state.dart';
import 'package:gangbook/widgets/user_image_bubble.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    final userState = Provider.of<UserState>(context, listen: false);
    final gang = Provider.of<GangState>(context, listen: false);
    if (gang != null && gang.gang != null) {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('meets_notifications') &&
          !prefs.getBool('meets_notifications')) {
        FirebaseMessaging.instance.unsubscribeFromTopic(gang.gang.id + "Meets");
      } else {
        FirebaseMessaging.instance.subscribeToTopic(gang.gang.id + "Meets");
      }
      if (prefs.containsKey('chat_notifications') &&
          !prefs.getBool('chat_notifications')) {
        FirebaseMessaging.instance.unsubscribeFromTopic(gang.gang.id + "Chat");
      } else {
        FirebaseMessaging.instance.subscribeToTopic(gang.gang.id + "Chat");
      }
      if (userState.user.uid == gang.gang.leader) {
        FirebaseMessaging.instance.subscribeToTopic(gang.gang.id + "Leader");
      }

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        final page = ModalRoute.of(context).runtimeType;
        print(page);
        if (message.from.contains('Chat')) {
          if (page == ChatScreen) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StreamProvider<ChatState>.value(
                value: DBStreams().getChat(gang.gang.id),
                initialData: null,
                child: MultiProvider(
                  providers: [
                    Provider<UserState>.value(
                      value: userState,
                    ),
                    Provider<GangState>.value(
                      value: gang,
                    )
                  ],
                  child: ChatScreen(),
                ),
              ),
            ),
          );
        }
      });
      FirebaseMessaging.onMessage.listen(
        (RemoteMessage message) {
          final page = ModalRoute.of(context).runtimeType;
          print(page);
          if (message.from.contains('Chat')) {
            if (page == ChatScreen) return;
            ScaffoldMessenger.of(_scaffoldkey.currentContext)
                .hideCurrentSnackBar();
            ScaffoldMessenger.of(_scaffoldkey.currentContext).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.chat_bubble),
                    Text(
                      message.notification.body,
                    ),
                  ],
                ),
              ),
            );
          } else if (message.from.contains('Meets')) {
            ScaffoldMessenger.of(_scaffoldkey.currentContext).showSnackBar(
              SnackBar(
                content: Text('new meet is schedulled! check in home page'),
              ),
            );
          } else if (message.from.contains('Leader')) {
            changePage(GangJoinRequestsScreen(openDrawer));
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
    if (decideToLeaveGang) {
      final gang = Provider.of<GangState>(context, listen: false);
      String newLeaderUid;
      if (user.uid == gang.gang.leader) {
        newLeaderUid = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('You are the leader, please choose new leader'),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: gang.gang.members.length,
                itemBuilder: (ctx, i) => ListTile(
                  title: Text(gang.gang.members[i].name),
                  onTap: () => Navigator.of(ctx).pop(gang.gang.members[i].uid),
                ),
              ),
            ),
          ),
        );
        if (newLeaderUid == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gang leader cannot leave the gang before choose new leader.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      showDialog(
        context: context,
        builder: (ctx) {
          gang.leaveGang(user, newLeaderUid).then((value) {
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
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: DrawerHeader(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          UserImagebubble(
                            uid: user.uid,
                            radius: MediaQuery.of(context).size.width * 0.1,
                            userImageUrl: user.profileImageUrl,
                            userName: user.fullName,
                          ),
                          FittedBox(
                            child: Text(
                              user.fullName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 30,
                              ),
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
                            if (_currentPage.runtimeType is GangScreen)
                              openDrawer();
                            else
                              changePage(GangScreen(openDrawer));
                          },
                          leading: Icon(
                            Icons.group,
                            color: Colors.white,
                          ),
                          title: Text(
                            'My gang',
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
                          onTap: () {
                            if (_currentPage.runtimeType is SettingsScreen)
                              openDrawer();
                            else
                              changePage(SettingsScreen(openDrawer));
                          },
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
                              Icons.group_add,
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
                            Icons.directions_walk_outlined,
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
