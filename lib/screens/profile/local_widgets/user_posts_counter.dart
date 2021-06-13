import 'package:flutter/material.dart';
import 'package:gangbook/state_managment/posts_feed.dart';
import 'package:provider/provider.dart';

class UserPostsCounter extends StatelessWidget {
  const UserPostsCounter({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final postsFeed = Provider.of<PostsFeed>(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(
                postsFeed.posts.length.toString(),
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                'Posts',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ],
          ),
          Column(
            children: [
              Text(
                postsFeed.likesCounter.toString(),
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                'likes',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
