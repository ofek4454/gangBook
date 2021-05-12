import 'package:flutter/material.dart';
import 'package:gangbook/models/post.dart';
import 'package:gangbook/widgets/whiteRoundedCard.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class PostItem extends StatelessWidget {
  final Post post;

  PostItem(this.post);

  String nameInitials(String fullName) {
    final splittedName = fullName.split(' ');
    return splittedName[0][0] + splittedName[1][0];
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final fieldHeight = screenSize.height * 0.1;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: WhiteRoundedCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: fieldHeight * 0.3,
                    child: Text(nameInitials(post.authorName).toUpperCase()),
                  ),
                  SizedBox(width: 10),
                  Text(
                    post.authorName,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Spacer(),
                  Text(
                    DateFormat('HH:mm dd/MM').format(post.createdAt.toDate()),
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
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: post.images.length + post.videos.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            alignment: Alignment.bottomLeft,
                            children: [
                              AspectRatio(
                                aspectRatio: 1 / 1,
                                child: index < post.videos.length
                                    ? PostVideoPlayer(url: post.videos[index])
                                    : Image.network(
                                        post.images[index - post.videos.length],
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
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
                              if (post.images.length + post.videos.length > 1)
                                Container(
                                  margin: EdgeInsets.only(left: 10, bottom: 10),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white60,
                                  ),
                                  child: Text(
                                      '${index + 1}/${post.images.length + post.videos.length}'),
                                )
                            ],
                          );
                        }),
                  ),
                ),
            ],
          ),
        ),
      ),
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
    controller.dispose();
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
      child: VideoPlayer(controller),
    );
  }
}
