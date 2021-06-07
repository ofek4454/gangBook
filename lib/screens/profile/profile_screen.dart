import 'package:flutter/material.dart';
import 'package:gangbook/screens/profile/local_widgets/profile_image_and_bg.dart';
import 'package:gangbook/screens/profile/local_widgets/saved_posts_feed.dart';
import 'package:gangbook/screens/profile/local_widgets/user_posts_feed.dart';
import 'package:gangbook/state_managment/posts_feed.dart';
import 'package:gangbook/state_managment/user_state.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  final Function openDrawer;

  ProfileScreen(this.openDrawer);

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        elevation: 0,
        title: Text(
          userState.user.fullName,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          color: Colors.white,
          icon: Icon(Icons.menu_rounded),
          onPressed: () => openDrawer(),
        ),
      ),
      body: Column(
        children: [
          ProfileImageAndBG(),
          DefaultTabController(
            length: 2,
            child: Expanded(
              child: Column(
                children: [
                  TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(
                        icon: Icon(Icons.grid_on),
                        text: 'My posts',
                      ),
                      Tab(
                        icon: Icon(Icons.bookmark_outline),
                        text: 'Saved',
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        ChangeNotifierProvider<PostsFeed>(
                          create: (context) => PostsFeed(),
                          child: UserPostsFeed(),
                        ),
                        ChangeNotifierProvider<PostsFeed>(
                          create: (context) => PostsFeed(),
                          child: SavedPostsFeed(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
