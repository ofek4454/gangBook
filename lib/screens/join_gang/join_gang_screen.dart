import 'package:barcode_scan_fix/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/screens/root/root.dart';
import 'package:gangbook/services/meets_db.dart';
import 'package:gangbook/services/gang_db.dart';
import 'package:gangbook/widgets/whiteRoundedCard.dart';
import 'package:provider/provider.dart';

class JoinGangScreen extends StatefulWidget {
  final UserModel user;

  JoinGangScreen(this.user);

  @override
  _JoinGangScreenState createState() => _JoinGangScreenState();
}

class _JoinGangScreenState extends State<JoinGangScreen> {
  bool isLoading = false;
  final idController = TextEditingController();

  Future<void> _join() async {
    setState(() {
      isLoading = true;
    });

    final res = await GangDB().joinGang(idController.text, widget.user);
    if (res == 'success') {
      Navigator.of(context).pop();
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _scan(BuildContext context) async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() {
        idController.text = barcode;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong, please try again.'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    }
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
                  'Join Gang',
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: idController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).secondaryHeaderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          labelText: 'Gang Id',
                          labelStyle: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor),
                          hintStyle: TextStyle(color: Colors.red),
                          prefixIcon: Icon(
                            Icons.people_outline,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                        ),
                      ),
                    ),
                    ClipOval(
                      child: Material(
                        color: Colors.transparent,
                        child: IconButton(
                          icon: Icon(Icons.qr_code_scanner_rounded),
                          onPressed: () => _scan(context),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                isLoading
                    ? CircularProgressIndicator()
                    : RaisedButton(
                        onPressed: () => _join(),
                        child: Text(
                          'Join',
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
