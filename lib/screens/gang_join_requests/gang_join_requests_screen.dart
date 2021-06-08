import 'package:flutter/material.dart';
import 'package:gangbook/services/user_db.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:gangbook/utils/names_initials.dart';
import 'package:provider/provider.dart';

class GangJoinRequestsScreen extends StatelessWidget {
  final Function openDrawer;

  GangJoinRequestsScreen(this.openDrawer);

  @override
  Widget build(BuildContext context) {
    final gangState = Provider.of<GangState>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded),
          onPressed: () => openDrawer(),
        ),
      ),
      body: gangState.gang.gangJoinRequest.isEmpty
          ? Center(
              child: Text(
                'This gang does not have join requests',
                style: Theme.of(context).textTheme.headline6,
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: gangState.gang.gangJoinRequest.length,
              itemBuilder: (context, i) {
                return FutureBuilder<Map<String, String>>(
                    future:
                        UserDB().getUserName(gangState.gang.gangJoinRequest[i]),
                    builder: (context, snapshot) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: snapshot.connectionState != ConnectionState.done
                            ? Center(
                                child: CircularProgressIndicator.adaptive(),
                              )
                            : Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        snapshot.data['imageUrl'] == null
                                            ? null
                                            : NetworkImage(
                                                snapshot.data['imageUrl']),
                                    backgroundColor:
                                        Theme.of(context).canvasColor,
                                    radius: 30,
                                    child: snapshot.data['imageUrl'] != null
                                        ? null
                                        : Text(
                                            NameInitials().getInitials(
                                                snapshot.data['name']),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.07,
                                            ),
                                          ),
                                  ),
                                  title: Text(snapshot.data['name']),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () {
                                          gangState.approveJoinRequest(gangState
                                              .gang.gangJoinRequest[i]);
                                        },
                                        icon: Icon(Icons.check),
                                        label: Text('Approve'),
                                        style: ButtonStyle(
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.green),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          gangState.denieJoinRequest(gangState
                                              .gang.gangJoinRequest[i]);
                                        },
                                        icon: Icon(Icons.cancel_outlined),
                                        label: Text('Denie'),
                                        style: ButtonStyle(
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      );
                    });
              },
            ),
    );
  }
}
