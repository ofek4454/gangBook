import 'package:flutter/material.dart';
import 'package:gangbook/screens/home/home_screen.dart';
import 'package:gangbook/screens/login/login_screen.dart';
import 'package:gangbook/screens/no_group/no_group_screen.dart';
import 'package:gangbook/screens/splash/splash_screen.dart';
import 'package:gangbook/state_managment/current_gang.dart';
import 'package:gangbook/state_managment/current_user.dart';
import 'package:provider/provider.dart';

enum AuthStatus {
  NotLoggedIn,
  NotInGroup,
  InGroup,
  Unknown,
}

class RootScreen extends StatefulWidget {
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  AuthStatus _authStatus = AuthStatus.Unknown;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final _currentUser = Provider.of<CurrentUser>(context, listen: false);
    final result = await _currentUser.tryAutoLogIn();

    if (result == 'success') {
      if (_currentUser.user.gangId != null) {
        setState(() {
          _authStatus = AuthStatus.InGroup;
        });
      } else {
        setState(() {
          _authStatus = AuthStatus.NotInGroup;
        });
      }
    } else {
      setState(() {
        _authStatus = AuthStatus.NotLoggedIn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_authStatus) {
      case AuthStatus.InGroup:
        return ChangeNotifierProvider(
          create: (ctx) => CurrentGang(),
          child: HomeScreen(),
        );
        break;
      case AuthStatus.NotInGroup:
        return NoGroupScreeen();
        break;
      case AuthStatus.Unknown:
        return SplashScreen();
        break;
      case AuthStatus.NotLoggedIn:
        return LoginScreen();
      default:
    }
  }
}
