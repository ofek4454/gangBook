import 'package:flutter/material.dart';
import 'package:gangbook/models/gang_model.dart';
import 'package:gangbook/models/post_model.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/screens/home/local_widgets/meeting_dialog.dart';
import 'package:gangbook/screens/home/local_widgets/posts_widgets/post_item.dart';
import 'package:gangbook/screens/home/local_widgets/posts_widgets/upload_post_field.dart';
import 'package:gangbook/services/posts_db.dart';
import 'package:gangbook/state_managment/post_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final Function openDrawer;
  HomeScreen(this.openDrawer);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Post> posts;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadPosts();
  }

  Future<void> loadPosts() async {
    final _currentGang = Provider.of<GangModel>(context, listen: false);
    if (_currentGang == null) return;
    posts = await PostsDB().loadPosts(_currentGang.id);

    setState(() {});
  }

  void uploadPost(Post post) {
    setState(() {
      posts.insert(0, post);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _currentGang = Provider.of<GangModel>(context);
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
        onRefresh: () => loadPosts(),
        child: Scrollbar(
          thickness: 6,
          child: ListView(
            padding: EdgeInsets.only(left: 20, right: 20),
            children: [
              SizedBox(height: 20),
              MeetingDialog(),
              SizedBox(height: 20),
              UploadPostField(uploadPost),
              SizedBox(height: 20),
              if (posts == null)
                Center(child: CircularProgressIndicator.adaptive()),
              if (posts != null)
                ...posts
                    .map(
                      (post) => ChangeNotifierProvider<PostState>(
                        create: (context) =>
                            PostState(post, user, _currentGang.id),
                        child: PostItem(),
                      ),
                    )
                    .toList(),
            ],
          ),
        ),
      ),
    );
  }
}
