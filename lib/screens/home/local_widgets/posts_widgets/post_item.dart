import 'package:flutter/material.dart';
import 'package:gangbook/screens/another_user_profile/another_user_profile_screen.dart';
import 'package:gangbook/screens/home/local_widgets/posts_widgets/comments_feed.dart';
import 'package:gangbook/screens/home/local_widgets/posts_widgets/likes_feed.dart';
import 'package:gangbook/screens/profile/profile_screen.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:gangbook/state_managment/post_state.dart';
import 'package:gangbook/state_managment/posts_feed.dart';
import 'package:gangbook/state_managment/user_state.dart';
import 'package:gangbook/utils/names_initials.dart';
import 'package:gangbook/widgets/user_image_bubble.dart';
import 'package:gangbook/widgets/whiteRoundedCard.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

enum MenuItem {
  Delete,
  Edit,
}

class PostItem extends StatelessWidget {
  PostItem({
    Key key,
  }) : super(key: key);

  void _comment(BuildContext context) {
    showModalBottomSheet<String>(
        context: context,
        builder: (ctx) {
          final controller = TextEditingController();
          return Container(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    autofocus: true,
                    controller: controller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    Navigator.of(ctx).pop(controller.text);
                  },
                  child: Text(
                    'Comment',
                    style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                )
              ],
            ),
          );
        }).then((comment) {
      if (comment != null && comment.isNotEmpty) {
        Provider.of<PostState>(context, listen: false).commentsOnPost(comment);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final fieldHeight = screenSize.height * 0.1;
    final userState = Provider.of<UserState>(context, listen: false);

    return Consumer<PostState>(
      builder: (context, postState, child) {
        final post = postState.post;
        final doIlike = post.doILike(userState.user.uid);
        final isUserSaved = userState.isPostSaved(post.id);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: WhiteRoundedCard(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (navCtx) => MultiProvider(
                                providers: [
                                  Provider<GangState>.value(
                                    value: Provider.of<GangState>(context),
                                  ),
                                  Provider<UserState>.value(
                                    value: Provider.of<UserState>(context),
                                  ),
                                ],
                                child: post.authorId == userState.user.uid
                                    ? ProfileScreen(null)
                                    : AnotherUserProfile(uid: post.authorId),
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            UserImagebubble(
                              radius: fieldHeight * 0.3,
                              userName: post.authorName,
                              userImageUrl: post.authorImage,
                              uid: post.authorId,
                            ),
                            SizedBox(width: 10),
                            Text(
                              post.authorName,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            Spacer(),
                            Text(
                              DateFormat('HH:mm dd/MM')
                                  .format(post.createdAt.toDate()),
                            ),
                            if (post.authorId == userState.user.uid)
                              PopupMenuButton<MenuItem>(
                                onSelected: (MenuItem value) {
                                  if (value == MenuItem.Delete) {
                                    Provider.of<PostsFeed>(context,
                                            listen: false)
                                        .deletePost(
                                            post.id, userState.user.gangId);
                                  }
                                  if (value == MenuItem.Edit) {
                                    //Edit
                                  }
                                },
                                icon: Icon(Icons.more_vert),
                                itemBuilder: (ctx) => [
                                  PopupMenuItem(
                                    child: Text('Delete'),
                                    value: MenuItem.Delete,
                                  ),
                                  PopupMenuItem(
                                    child: Text('Edit'),
                                    value: MenuItem.Edit,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        post.content,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      SizedBox(height: 10),
                      if (post.images.isNotEmpty || post.videos.isNotEmpty)
                        ClipRRect(
                          borderRadius:
                              BorderRadius.vertical(bottom: Radius.circular(4)),
                          child: Container(
                            width: double.infinity,
                            height: screenSize.width - 100,
                            child: PageView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  post.images.length + post.videos.length,
                              itemBuilder: (ctx, index) {
                                return Stack(
                                  alignment: Alignment.bottomLeft,
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 1 / 1,
                                      child: index < post.videos.length
                                          ? PostVideoPlayer(
                                              url: post.videos[index])
                                          : Image.network(
                                              post.images[
                                                  index - post.videos.length],
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress != null) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }
                                                return child;
                                              },
                                            ),
                                    ),
                                    if (post.images.length +
                                            post.videos.length >
                                        1)
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 10, bottom: 10),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.white60,
                                        ),
                                        child: Text(
                                            '${index + 1}/${post.images.length + post.videos.length}'),
                                      )
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        doIlike ? Icons.favorite : Icons.favorite_border,
                      ),
                      color: doIlike ? Colors.red : Colors.black,
                      onPressed: () {
                        if (doIlike) {
                          postState.unLikePost();
                        } else {
                          postState.likePost();
                        }
                      },
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (ctx) => MultiProvider(
                                providers: [
                                  Provider<UserState>.value(
                                    value: Provider.of<UserState>(context),
                                  ),
                                  Provider<GangState>.value(
                                    value: Provider.of<GangState>(context),
                                  ),
                                ],
                                child: LikesFeed(post.likes),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              '${post.likes.length} likes',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.comment),
                      color: Colors.black,
                      onPressed: () => _comment(context),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (ctx) => MultiProvider(
                                providers: [
                                  Provider<UserState>.value(
                                    value: Provider.of<UserState>(context),
                                  ),
                                  Provider<GangState>.value(
                                    value: Provider.of<GangState>(context),
                                  ),
                                ],
                                child: CommentsFeed(
                                  post,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              '${post.comments.length} comments',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ClipOval(
                      child: Material(
                        color: Colors.transparent,
                        child: IconButton(
                          icon: Icon(
                            isUserSaved
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                          ),
                          onPressed: () => isUserSaved
                              ? userState.unSavePost(post.id)
                              : userState.savePost(post.id),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class PostVideoPlayer extends StatefulWidget {
  const PostVideoPlayer({
    Key key,
    @required this.url,
  }) : super(key: key);

  final String url;

  @override
  _PostVideoPlayerState createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<PostVideoPlayer> {
  VideoPlayerController controller;

  @override
  void initState() {
    controller = VideoPlayerController.network(widget.url)
      ..initialize().then((value) {
        if (controller != null)
          setState(() {
            controller.setLooping(true);
            controller.setVolume(0);
            controller.play();
          });
      });

    super.initState();
  }

  @override
  void dispose() {
    controller.pause();
    controller.dispose();
    controller = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (controller.value.volume == 0)
            controller.setVolume(1);
          else
            controller.setVolume(0);
        },
        child: controller.value.isInitialized
            ? VideoPlayer(controller)
            : Center(child: CircularProgressIndicator.adaptive()));
  }
}
