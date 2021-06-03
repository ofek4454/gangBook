import 'package:flutter/material.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/screens/home/local_widgets/meeting_dialog.dart';
import 'package:gangbook/screens/home/local_widgets/posts_widgets/post_item.dart';
import 'package:gangbook/screens/home/local_widgets/posts_widgets/upload_post_field.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:gangbook/state_managment/post_state.dart';
import 'package:gangbook/state_managment/posts_feed.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final Function openDrawer;
  HomeScreen(this.openDrawer);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final _currentGang = Provider.of<GangState>(context, listen: false);
    if (_currentGang != null)
      Provider.of<PostsFeed>(context, listen: false)
          .loadPosts(_currentGang.gang.id);
  }

  @override
  Widget build(BuildContext context) {
    final _currentGang = Provider.of<GangState>(context);
    final user = Provider.of<UserModel>(context);

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
        onRefresh: () => Provider.of<PostsFeed>(context, listen: false)
            .loadPosts(_currentGang.gang.id),
        child: Scrollbar(
          thickness: 6,
          child: Consumer<PostsFeed>(
            builder: (context, postsFeed, child) {
              return ListView(
                padding: EdgeInsets.only(left: 20, right: 20),
                children: [
                  SizedBox(height: 10),
                  MeetingDialog(),
                  SizedBox(height: 20),
                  UploadPostField(),
                  SizedBox(height: 10),
                  if (postsFeed.posts == null) ...{
                    Center(child: CircularProgressIndicator.adaptive()),
                  } else ...{
                    ...postsFeed.posts
                        .map(
                          (post) => ChangeNotifierProvider<PostState>(
                            create: (context) =>
                                PostState(post, user, _currentGang.gang.id),
                            child: PostItem(),
                          ),
                        )
                        .toList(),
                  }
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
