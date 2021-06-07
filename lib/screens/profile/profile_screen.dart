import 'package:flutter/material.dart';
import 'package:gangbook/screens/profile/local_widgets/profile_image_and_bg.dart';
import 'package:gangbook/screens/profile/local_widgets/saved_posts_feed.dart';
import 'package:gangbook/screens/profile/local_widgets/user_posts_feed.dart';
import 'package:gangbook/state_managment/posts_feed.dart';
import 'package:gangbook/state_managment/user_state.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final Function openDrawer;

  ProfileScreen(this.openDrawer);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {
        scrollController.animateTo(0,
            duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final screenSize = MediaQuery.of(context).size;
    final userImageRaduis = screenSize.width * 0.25;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          controller: scrollController,
          headerSliverBuilder: (context, value) {
            return [
              SliverAppBar(
                expandedHeight: userImageRaduis * 3,
                flexibleSpace: FlexibleSpaceBar(
                  background: ProfileImageAndBG(userImageRaduis),
                ),
                pinned: true,
                elevation: 0,
                title: Text(
                  userState.user.fullName,
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
                leading: IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.menu_rounded),
                  onPressed: () => widget.openDrawer(),
                ),
                bottom: TabBar(
                  controller: tabController,
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
              ),
            ];
          },
          body: TabBarView(
            controller: tabController,
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
      ),
    );
  }
}
