import 'package:flutter/material.dart';

import './local_widgets/login_form.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                Container(
                  padding: EdgeInsets.only(top: 50),
                  child: Image.asset(
                    'assets/images/logo.png',
                    // width: MediaQuery.of(context).size.width * 0.7,
                    height: 170,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 50),
                LoginForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
