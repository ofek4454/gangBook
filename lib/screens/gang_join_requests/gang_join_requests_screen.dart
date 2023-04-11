import 'package:flutter/material.dart';
import 'package:gangbook/screens/gang_join_requests/local_widgets/user_request_field.dart';
import 'package:gangbook/services/user_db.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:provider/provider.dart';

class GangJoinRequestsScreen extends StatelessWidget {
  final Function openDrawer;

  GangJoinRequestsScreen(this.openDrawer);

  @override
  Widget build(BuildContext context) {
    final gangState = Provider.of<GangState>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded),
          color: Colors.black,
          onPressed: () => openDrawer(),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Is this gang is private?',
                style: Theme.of(context).textTheme.headline6,
              ),
              Switch.adaptive(
                value: gangState.gang.isPrivate,
                onChanged: (newVal) {
                  gangState.chaneGangPrivacyMode(newVal);
                },
                activeColor: Colors.green,
                inactiveTrackColor: Colors.red,
              ),
              Tooltip(
                showDuration: Duration(seconds: 5),
                message: "If the gang is in private mode,\n"
                    "when member request to join you as a gang leader\n"
                    "will need to approve his request before he can go in!",
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                child: Icon(Icons.info_outline),
              ),
            ],
          ),
          Expanded(
            child: gangState.gang.joinRequests.isEmpty
                ? Center(
                    child: Text(
                      'This gang does not have join requests',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: gangState.gang.joinRequests.length,
                    itemBuilder: (context, i) {
                      return FutureBuilder<Map<String, String>>(
                          future: UserDB()
                              .getUserData(gangState.gang.joinRequests[i]),
                          builder: (context, snapshot) => UserRequestField(
                                uid: gangState.gang.joinRequests[i],
                                userData: snapshot.data,
                              ));
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
