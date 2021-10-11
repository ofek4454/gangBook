import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:gangbook/screens/root/root.dart';
import 'package:gangbook/services/auth.dart';
import 'package:gangbook/widgets/whiteRoundedCard.dart';

import '../../signup/signup_screen.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  Map<String, String> values = {
    'email': '',
    'password': '',
  };

  final _passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    var isValidae = _formKey.currentState.validate();
    if (!isValidae) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    _formKey.currentState.save();
    try {
      await Auth().logInUser(
        email: values['email'],
        password: values['password'],
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print(e);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      final res = await Auth().logInWithGoogle();
      if (res) {
        moveToHome();
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong, please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void moveToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => RootScreen(),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WhiteRoundedCard(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              'Log In',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.alternate_email),
                hintText: 'Email',
              ),
              validator: (val) {
                if (RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(val)) {
                  return null;
                }
                return 'email address is not valid';
              },
              onSaved: (val) => values['email'] = val,
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outline),
                hintText: 'Password',
              ),
              obscureText: true,
              validator: (value) {
                if (value.isEmpty || value.length < 6) {
                  return 'Password should be at least 6 characters';
                }
                return null;
              },
              onSaved: (val) => values['password'] = val,
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : RaisedButton(
                    onPressed: () => _submit(),
                    child: Text(
                      'Log In',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SignupScreen(),
                  ),
                );
              },
              child: Text('Don\'t have an account? SignUp here'),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            SignInButton(
              Buttons.GoogleDark,
              onPressed: () => signInWithGoogle(),
              shape: ContinuousRectangleBorder(),
            )
          ],
        ),
      ),
    );
  }
}
