import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gangbook/models/gang_model.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

class InviteToGangScreen extends StatelessWidget {
  final Function openDrawer;

  InviteToGangScreen(this.openDrawer);

  @override
  Widget build(BuildContext context) {
    final gang = Provider.of<GangState>(context, listen: false).gang;
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu_rounded),
            onPressed: () => openDrawer(),
          ),
        ),
        body: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                gang.name,
                style: Theme.of(context).textTheme.headline5,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SelectableText(
                    gang.id,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: gang.id));
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gang id copied successfully!')),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              QrImage(
                data: gang.id,
                version: QrVersions.auto,
                size: MediaQuery.of(context).size.width * 0.6,
              ),
              SizedBox(height: 20),
              TextButton.icon(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                ),
                onPressed: () {
                  Share.share(
                    'Hi, Join my gang in GangBook!\n'
                    'use this id to enter my gang \n'
                    '${gang.id}',
                  );
                },
                icon: Icon(Icons.share),
                label: Text('Share gang'),
              ),
            ],
          ),
        ));
  }
}
