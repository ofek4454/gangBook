import 'package:flutter/material.dart';
import 'package:gangbook/models/post.dart';
import 'package:gangbook/widgets/whiteRoundedCard.dart';
import 'package:intl/intl.dart';

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
              if (post.images.isNotEmpty)
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(4)),
                  child: Container(
                    height: screenSize.width * 0.45,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: post.images.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: AspectRatio(
                          aspectRatio: 1 / 1,
                          child: Image.network(
                            post.images[index],
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress != null) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return child;
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
