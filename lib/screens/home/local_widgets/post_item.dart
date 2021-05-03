import 'package:flutter/material.dart';
import 'package:gangbook/widgets/whiteRoundedCard.dart';
import 'package:intl/intl.dart';

class PostItem extends StatelessWidget {
  final Map<String, String> data;

  PostItem(this.data);

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
                    child: Text(nameInitials(data['author']).toUpperCase()),
                  ),
                  SizedBox(width: 10),
                  Text(
                    data['title'],
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(width: 5),
                  Icon(
                    data['type'] == 'private'
                        ? Icons.lock_outline
                        : Icons.public,
                    color: data['type'] == 'private' ? Colors.grey : null,
                  ),
                  Spacer(),
                  Text(
                    DateFormat('HH:mm dd/MM')
                        .format(DateTime.parse(data['date'])),
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
                data['content'],
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 10),
              if (data['image'] != null)
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(4)),
                  child: Container(
                    height: screenSize.width * 0.45,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          data['image'],
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
            ],
          ),
        ),
      ),
    );
  }
}
