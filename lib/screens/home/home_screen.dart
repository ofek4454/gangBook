import 'package:flutter/material.dart';
import 'package:gangbook/screens/home/local_widgets/meeting_dialog.dart';
import 'package:gangbook/screens/home/local_widgets/posts_widgets/post_item.dart';
import 'package:gangbook/screens/home/local_widgets/posts_widgets/upload_post_field.dart';
import 'package:gangbook/screens/no_group/no_group_screen.dart';
import 'package:gangbook/screens/root/root.dart';
import 'package:gangbook/state_managment/current_gang.dart';
import 'package:gangbook/state_managment/current_user.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final Function openDrawer;
  HomeScreen(this.openDrawer);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void initState() {
    super.initState();

    final _currentUser = Provider.of<CurrentUser>(context, listen: false);
    final _currentGang = Provider.of<CurrentGang>(context, listen: false);

    _currentGang.updateStateFromDB(_currentUser.user.gangId);
  }

  @override
  Widget build(BuildContext context) {
    final _currentGang = Provider.of<CurrentGang>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.messenger_outline_rounded),
            onPressed: () {},
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.menu_rounded),
          onPressed: () => widget.openDrawer(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _currentGang.updateStateFromDB(_currentGang.gang.id),
        child: Scrollbar(
          thickness: 6,
          child: ListView(
            padding: EdgeInsets.only(left: 20, right: 20),
            children: [
              SizedBox(height: 20),
              MeetingDialog(),
              SizedBox(height: 20),
              UploadPostField(),
              SizedBox(height: 20),
              //PostsFeed(),
              if (_currentGang.gang.posts != null &&
                  _currentGang.gang.posts.isNotEmpty)
                ..._currentGang.gang.posts
                    .map((post) => PostItem(post))
                    .toList(),

              SizedBox(height: 20),
              RaisedButton(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => NoGroupScreeen())),
                child: Text('noGroup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
