import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  final Function openDrawer;

  const SettingsScreen(this.openDrawer, {Key key}) : super(key: key);

  void removeChatNotification(BuildContext context) {
    final gang = Provider.of<GangState>(context, listen: false).gang;
    FirebaseMessaging.instance.unsubscribeFromTopic(gang.id + "Chat");
  }

  void addChatNotification(BuildContext context) {
    final gang = Provider.of<GangState>(context, listen: false).gang;
    FirebaseMessaging.instance.subscribeToTopic(gang.id + "Chat");
  }

  void removeMeetsNotification(BuildContext context) {
    final gang = Provider.of<GangState>(context, listen: false).gang;
    FirebaseMessaging.instance.unsubscribeFromTopic(gang.id + "Meets");
  }

  void addMeetsNotification(BuildContext context) {
    final gang = Provider.of<GangState>(context, listen: false).gang;
    FirebaseMessaging.instance.subscribeToTopic(gang.id + "Meets");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded),
          onPressed: () => openDrawer(),
          color: Colors.black,
        ),
      ),
      body: FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, prefs) {
            if (prefs.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }

            return StatefulBuilder(
              builder: (context, setState) {
                bool chatNotifications;
                bool groupNotifications;
                chatNotifications = prefs.data.containsKey('chat_notifications')
                    ? prefs.data.getBool('chat_notifications')
                    : true;
                groupNotifications =
                    prefs.data.containsKey('meets_notifications')
                        ? prefs.data.getBool('meets_notifications')
                        : true;
                return ListView(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    SwitchListTile.adaptive(
                      activeColor: Colors.green,
                      inactiveTrackColor: Colors.red,
                      title: Text('Chat notifications'),
                      value: chatNotifications,
                      onChanged: (val) async {
                        await prefs.data.setBool('chat_notifications', val);
                        setState(() {});
                        if (val == true)
                          addChatNotification(context);
                        else
                          removeChatNotification(context);
                      },
                    ),
                    SwitchListTile.adaptive(
                      activeColor: Colors.green,
                      inactiveTrackColor: Colors.red,
                      title: Text('Meets notifications'),
                      value: groupNotifications,
                      onChanged: (val) async {
                        await prefs.data.setBool('meets_notifications', val);
                        setState(() {});
                        if (val == true)
                          addMeetsNotification(context);
                        else
                          removeMeetsNotification(context);
                      },
                    ),
                  ],
                );
              },
            );
          }),
    );
  }
}
