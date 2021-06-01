import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gangbook/models/gang_model.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/screens/home/local_widgets/posts_widgets/comments_feed.dart';
import 'package:gangbook/screens/home/local_widgets/posts_widgets/likes_feed.dart';
import 'package:gangbook/state_managment/post_provider.dart';
import 'package:gangbook/utils/names_initials.dart';
import 'package:gangbook/widgets/whiteRoundedCard.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PostItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final fieldHeight = screenSize.height * 0.1;
    final user = Provider.of<UserModel>(context, listen: false);
    return Consumer<PostState>(
      builder: (context, postState, child) {
        final post = postState.post;
        final doIlike = post.doILike(user.uid);

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
                      Row(
                        children: [
                          CircleAvatar(
                            radius: fieldHeight * 0.3,
                            child: Text(
                                NameInitials().getInitials(post.authorName)),
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
                          /*PopupMenuButton(
                          onSelected: (MenuItem value) {
                            if (value == MenuItem.DELETE) _deletePost(context);
                            if (value == MenuItem.EDIT) {
                              images = [...widget.post.images];
                              newImages = [];
                              setState(() {
                                isEdit = true;
                              });
                            }
                            if (value == MenuItem.PIN) _pinPost(context);
                          },
                          icon: Icon(Icons.more_vert),
                          itemBuilder: (ctx) => [
                            PopupMenuItem(
                              child: widget.post.isPinned
                                  ? Text(Strings.UNPIN[Strings.lng])
                                  : Text(Strings.PIN_POST[Strings.lng]),
                              value: MenuItem.PIN,
                            ),
                            PopupMenuItem(
                              child: Text(Strings.DELETE_POST[Strings.lng]),
                              value: MenuItem.DELETE,
                            ),
                            PopupMenuItem(
                              child: Text(Strings.UPDATE_POST[Strings.lng]),
                              value: MenuItem.EDIT,
                            ),
                          ],
                        ),*/
                        ],
                      ),
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
                              builder: (ctx) => LikesFeed(post.likes),
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
                      onPressed: () {
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
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }).then((comment) {
                          if (comment != null && comment.isNotEmpty) {
                            Provider.of<PostState>(context, listen: false)
                                .commentsOnPost(comment);
                          }
                        });
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
                              builder: (ctx) => CommentsFeed(
                                post,
                                Provider.of<GangModel>(context, listen: false),
                                user,
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
