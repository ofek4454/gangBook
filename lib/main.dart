import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gangbook/screens/root/root.dart';
import 'package:gangbook/state_managment/current_user.dart';
import 'package:provider/provider.dart';

import './utils/appTheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CurrentUser(),
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child),
        title: 'GangBook',
        debugShowCheckedModeBanner: false,
        theme: AppTheme().buildTheme(),
        home: RootScreen(),
      ),
    );
  }
}
