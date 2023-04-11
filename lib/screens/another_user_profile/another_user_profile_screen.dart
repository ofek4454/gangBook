import 'package:flutter/material.dart';
import 'package:gangbook/screens/profile/local_widgets/profile_image_and_bg.dart';
import 'package:gangbook/screens/profile/local_widgets/user_posts_feed.dart';
import 'package:gangbook/services/user_db.dart';
import 'package:gangbook/state_managment/posts_feed.dart';
import 'package:provider/provider.dart';

class AnotherUserProfile extends StatelessWidget {
  final String uid;
  const AnotherUserProfile({@required this.uid, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final userImageRaduis = screenSize.width * 0.25;
    return Scaffold(
      body: FutureBuilder<Map<String, String>>(
          future: UserDB().getUserData(uid),
          builder: (context, snapshot) {
            print(snapshot.data);
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            if (snapshot.data == null) {
              return Center(
                child: Text(
                  'This user is not longer availible',
                  style: Theme.of(context).textTheme.headline6,
                ),
              );
            }
            return NestedScrollView(
              headerSliverBuilder: (context, value) {
                return [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    expandedHeight: userImageRaduis * 3,
                    flexibleSpace: FlexibleSpaceBar(
                      background: ProfileImageAndBG(
                        userImageRaduis,
                        imageUrl: snapshot.data['imageUrl'],
                        isEditable: false,
                      ),
                    ),
                    pinned: true,
                    elevation: 0,
                    title: Text(
                      snapshot.data['name'],
                      style: TextStyle(color: Colors.white),
                    ),
                    centerTitle: true,
                  ),
                ];
              },
              body: ChangeNotifierProvider<PostsFeed>(
                create: (context) => PostsFeed(),
                child: UserPostsFeed(
                  uid: uid,
                ),
              ),
            );
          }),
    );
  }
}
