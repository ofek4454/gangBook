import 'package:flutter/material.dart';
import 'package:gangbook/screens/home/local_widgets/post_item.dart';
import 'package:gangbook/state_managment/current_gang.dart';
import 'package:provider/provider.dart';

class PostsFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final posts = Provider.of<CurrentGang>(context).gang.posts;
    return posts == null
        ? Container()
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            addAutomaticKeepAlives: false,
            itemCount: posts.length,
            itemBuilder: (ctx, i) => PostItem(posts[i]),
          );
  }
}
