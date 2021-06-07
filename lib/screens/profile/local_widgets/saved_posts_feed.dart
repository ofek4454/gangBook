import 'package:flutter/material.dart';
import 'package:gangbook/screens/home/local_widgets/posts_widgets/post_item.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:gangbook/state_managment/post_state.dart';
import 'package:gangbook/state_managment/posts_feed.dart';
import 'package:gangbook/state_managment/user_state.dart';
import 'package:provider/provider.dart';

class SavedPostsFeed extends StatefulWidget {
  @override
  _SavedPostsFeedState createState() => _SavedPostsFeedState();
}

class _SavedPostsFeedState extends State<SavedPostsFeed> {
  void didChangeDependencies() {
    super.didChangeDependencies();
    final _currentGang = Provider.of<GangState>(context, listen: false);
    final _userState = Provider.of<UserState>(context, listen: false);

    if (_currentGang != null)
      Provider.of<PostsFeed>(context, listen: false).loadSavedPosts(
          _currentGang.gang.id,
          _userState.user.uid,
          _userState.user.savedPosts);
  }

  @override
  Widget build(BuildContext context) {
    final _currentGang = Provider.of<GangState>(context);
    final user = Provider.of<UserState>(context).user;
    return Consumer<PostsFeed>(
      builder: (context, postsFeed, child) {
        if (postsFeed.posts == null)
          return Center(child: CircularProgressIndicator.adaptive());
        if (postsFeed.posts.isEmpty)
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'You dont have saved posts yet!',
                style: Theme.of(context).textTheme.headline6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'to save hit the save (',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Icon(Icons.bookmark_border_outlined),
                  Text(
                    ') icon.',
                    style: Theme.of(context).textTheme.headline6,
                  )
                ],
              )
            ],
          );
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shrinkWrap: true,
          primary: false,
          itemCount: postsFeed.posts.length,
          itemBuilder: (listContext, index) {
            final post = postsFeed.posts[index];
            return ChangeNotifierProvider<PostState>(
              key: ValueKey(post.id),
              create: (providerContext) =>
                  PostState(post, user, _currentGang.gang.id),
              child: PostItem(),
            );
          },
        );
      },
    );
  }
}
