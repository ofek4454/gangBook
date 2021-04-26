import 'package:flutter/material.dart';
import 'package:gangbook/screens/create_gang/create_gang_screen.dart';
import 'package:gangbook/screens/join_gang/join_gang_screen.dart';

class NoGroupScreeen extends StatelessWidget {
  void _goToCreateGang(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateGangScreen(),
      ),
    );
  }

  void _goToJoinGang(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JoinGangScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 70),
              child: Image.asset(
                'assets/images/logo.png',
                height: 170,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 50),
            Text(
              'Welcome To GangBook',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'LibreBaskerville',
                fontSize: 45,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Since you are not in a gang you can\n' +
                  'select to join a gang or create a gang',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
            Spacer(),
            Container(
              height: 45,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: RaisedButton(
                      onPressed: () => _goToJoinGang(context),
                      color: Theme.of(context).canvasColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: Theme.of(context).secondaryHeaderColor,
                          width: 3,
                        ),
                      ),
                      child: Text(
                        'Join',
                        style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: RaisedButton(
                      onPressed: () => _goToCreateGang(context),
                      child: Text(
                        'Create',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
