import 'package:flutter/material.dart';

class GangScreen extends StatelessWidget {
  final Function openDrawer;
  const GangScreen(this.openDrawer, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded),
          onPressed: () => openDrawer(),
        ),
      ),
    );
  }
}
