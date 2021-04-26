import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: MediaQuery.of(context).size.width * 0.7,
            ),
            SizedBox(height: 20),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
