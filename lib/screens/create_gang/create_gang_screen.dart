import 'package:flutter/material.dart';
import 'package:gangbook/screens/root/root.dart';
import 'package:gangbook/services/database.dart';
import 'package:gangbook/state_managment/current_user.dart';
import 'package:gangbook/widgets/whiteRoundedCard.dart';
import 'package:provider/provider.dart';

class CreateGangScreen extends StatefulWidget {
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
    final _currentUser = Provider.of<CurrentUser>(context, listen: false);
    String result =
        await AppDB().createGang(nameController.text, _currentUser.user);
    if (result == 'success') {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => RootScreen(),
          ),
          (route) => false);
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
