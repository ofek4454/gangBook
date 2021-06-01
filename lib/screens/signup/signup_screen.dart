import 'package:flutter/material.dart';

import './local_widgets/signup_form.dart';

class SignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 35.0, left: 20.0),
              child: BackButton(),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                SizedBox(height: 50),
                SignUpForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
