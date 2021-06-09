import 'package:flutter/material.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:gangbook/utils/names_initials.dart';
import 'package:provider/provider.dart';

class UserRequestField extends StatelessWidget {
  final Map<String, String> userData;
  final String uid;

  UserRequestField({this.userData, this.uid});

  @override
  Widget build(BuildContext context) {
    final gangState = Provider.of<GangState>(context, listen: false);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: userData == null
          ? Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: userData['imageUrl'] == null
                      ? null
                      : NetworkImage(userData['imageUrl']),
                  backgroundColor: Theme.of(context).canvasColor,
                  radius: 30,
                  child: userData['imageUrl'] != null
                      ? null
                      : Text(
                          NameInitials().getInitials(userData['name']),
                          style: TextStyle(
                            color: Theme.of(context).secondaryHeaderColor,
                            fontSize: MediaQuery.of(context).size.width * 0.07,
                          ),
                        ),
                ),
                title: Text(userData['name']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        gangState.approveJoinRequest(uid);
                      },
                      icon: Icon(Icons.check),
                      label: Text('Approve'),
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        gangState.denieJoinRequest(uid);
                      },
                      icon: Icon(Icons.cancel_outlined),
                      label: Text('Denie'),
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
