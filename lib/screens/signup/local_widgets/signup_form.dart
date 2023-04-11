import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gangbook/services/auth.dart';
import 'package:provider/provider.dart';
import '../../../widgets/whiteRoundedCard.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  Map<String, String> values = {
    'email': '',
    'fullname': '',
    'password': '',
    'confirmpassword': '',
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
      final res = await Auth().signUpUser(
        email: values['email'],
        password: values['password'],
        name: values['fullname'],
      );
      if (res) {
        Navigator.of(context).pop();
      }
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

  @override
  Widget build(BuildContext context) {
    return WhiteRoundedCard(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              'Sign Up',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person_outline),
                hintText: 'Full Name',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'this field is required';
                }
                return null;
              },
              onSaved: (val) => values['fullname'] = val,
            ),
            SizedBox(height: 10),
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
              controller: _passwordController,
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
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_open_outlined),
                hintText: 'Confim Password',
              ),
              obscureText: true,
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'passwords dont match';
                }
                return null;
              },
              onSaved: (val) => values['confirmpassword'] = val,
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => _submit(),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
