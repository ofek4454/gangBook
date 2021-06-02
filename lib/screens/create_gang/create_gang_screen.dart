import 'package:flutter/material.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/screens/root/root.dart';
import 'package:gangbook/services/meets_db.dart';
import 'package:gangbook/services/gang_db.dart';
import 'package:gangbook/widgets/whiteRoundedCard.dart';
import 'package:provider/provider.dart';

class CreateGangScreen extends StatefulWidget {
  final UserModel user;

  CreateGangScreen(this.user);

  @override
  _CreateGangScreenState createState() => _CreateGangScreenState();
}

class _CreateGangScreenState extends State<CreateGangScreen> {
  bool isLoading = false;
  final nameController = TextEditingController();

  Future<void> _create() async {
    setState(() {
      isLoading = true;
    });
    final res = await GangDB().createGang(nameController.text, widget.user);
    if (res == 'success') {
      Navigator.of(context).pop();
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: WhiteRoundedCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Create new gang',
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).secondaryHeaderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    labelText: 'Gang Name',
                    labelStyle: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor),
                    hintStyle: TextStyle(color: Colors.red),
                    prefixIcon: Icon(
                      Icons.people_outline,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                isLoading
                    ? CircularProgressIndicator()
                    : RaisedButton(
                        onPressed: () => _create(),
                        child: Text(
                          'Create',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
