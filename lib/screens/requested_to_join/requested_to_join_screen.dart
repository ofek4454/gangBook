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
            body: Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('You request to join "${snapshot.data}" gang'),
                  SizedBox(height: 10),
                  Text('Wait for the gang leader to approve you request'),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
