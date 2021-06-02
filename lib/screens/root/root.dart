import 'package:flutter/material.dart';
import 'package:gangbook/models/auth_model.dart';
import 'package:gangbook/models/gang_model.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/screens/drawer/app_drawer.dart';
import 'package:gangbook/screens/login/login_screen.dart';
import 'package:gangbook/screens/not_in_gang/not_in_gang_screen.dart';
import 'package:gangbook/screens/splash/splash_screen.dart';
import 'package:gangbook/services/database_streams.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:provider/provider.dart';

enum AuthStatus {
  NotLoggedIn,
  LoggedIn,
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
    final _auth = Provider.of<AuthModel>(context);
    if (_auth != null) {
      setState(() {
        _authStatus = AuthStatus.LoggedIn;
      });
    } else {
      setState(() {
        _authStatus = AuthStatus.NotLoggedIn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_authStatus) {
      case AuthStatus.NotLoggedIn:
        return LoginScreen();
      case AuthStatus.LoggedIn:
        final _auth = Provider.of<AuthModel>(context);

        return StreamProvider<UserModel>.value(
          initialData: null,
          value: DBStreams().getCurrentUser(_auth.uid),
          child: LoggedIn(),
        );
        break;
      case AuthStatus.Unknown:
        return SplashScreen();
        break;
      default:
    }
  }
}

class LoggedIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserModel>(context);
    if (currentUser == null) {
      return SplashScreen();
    }
    if (currentUser.gangId == null) {
      return NotInGangScreeen();
    } else {
      return StreamProvider<GangState>.value(
        initialData: null,
        value: DBStreams().getCurrentGang(currentUser.gangId),
        child: AppDrawer(),
      );
    }
  }
}
