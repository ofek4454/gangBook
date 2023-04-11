import 'package:flutter/material.dart';
import 'package:gangbook/screens/splash/splash_screen.dart';
import 'package:gangbook/services/gang_db.dart';
import 'package:gangbook/state_managment/user_state.dart';
import 'package:provider/provider.dart';

class RequestedToJoinScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context, listen: false);
    return FutureBuilder<String>(
      future: GangDB().getGangName(userState.user.gangJoinRequest),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SplashScreen();
        } else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: TextButton.icon(
                onPressed: () {
                  GangDB().denieJoinRequest(
                    userState.user.gangJoinRequest,
                    userState.user.uid,
                  );
                },
                icon: Icon(Icons.cancel),
                label: Text('Cancel request'),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
              ),
            ),
            body: Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'You request to join "${snapshot.data}"',
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Wait for the gang leader to approve your request',
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
