import 'package:flutter/material.dart';
import 'package:gangbook/screens/home/local_widgets/post_item.dart';

class PostsFeed extends StatelessWidget {
  Map<String, String> data = {
    'title': 'post title',
    'content': 'someContent',
    'type': 'private',
    'image':
        'https://static.remove.bg/remove-bg-web/2a274ebbb5879d870a69caae33d94388a88e0e35/assets/start-0e837dcc57769db2306d8d659f53555feb500b3c5d456879b9c843d1872e7baa.jpg',
    'author': 'ofek gorgi',
    'date': DateTime.now().toIso8601String(),
  };

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (ctx, i) => PostItem(data),
    );
  }
}
