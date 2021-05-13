import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gangbook/screens/home/home_screen.dart';
import 'package:gangbook/screens/root/root.dart';
import 'package:gangbook/state_managment/current_user.dart';
import 'package:gangbook/utils/names_initials.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  Widget _currentPage;
  bool isOpen = false;
  Duration duration = Duration(milliseconds: 500);
  double value = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = HomeScreen(openDrawer);
  }

  void openDrawer() {
    print(value);
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

  Future<void> _signout() async {
    String result =
        await Provider.of<CurrentUser>(context, listen: false).signOut();
    if (result == 'success') {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => RootScreen()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<CurrentUser>(context, listen: false);
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w500,
    );
    return Scaffold(
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
                  DrawerHeader(
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).canvasColor,
                          radius: MediaQuery.of(context).size.width * 0.1,
                          child: Text(
                            NameInitials()
                                .getInitials(currentUser.user.fullName),
                            style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.07,
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Text(
                          currentUser.user.fullName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          onTap: () {},
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
                          onTap: () {},
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
                          onTap: () {},
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
                        ListTile(
                          onTap: () {},
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
                      child: _currentPage,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
