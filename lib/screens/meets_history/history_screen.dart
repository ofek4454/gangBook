import 'package:flutter/material.dart';
import 'package:gangbook/models/auth_model.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/models/gang_model.dart';
import 'package:gangbook/models/meet_model.dart';
import 'package:gangbook/screens/home/local_widgets/meeting_widgets/event_members_arriving_list.dart';
import 'package:gangbook/services/meets_db.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:gangbook/state_managment/meet_state.dart';
import 'package:gangbook/widgets/whiteRoundedCard.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatelessWidget {
  final Function openDrawer;

  HistoryScreen(this.openDrawer);

  int userArriveTo(BuildContext context, List<MeetModel> meets) {
    final uid = Provider.of<AuthModel>(context, listen: false).uid;
    int retVal = 0;

    for (MeetModel meet in meets) {
      try {
        if (meet.membersAreComming
                .firstWhere((eventMember) => eventMember.uid == uid)
                .isComming ==
            ConfirmationType.Arrive) {
          retVal++;
        }
      } catch (e) {}
    }

    return retVal;
  }

  @override
  Widget build(BuildContext context) {
    final currentGang = Provider.of<GangState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded),
          onPressed: () => openDrawer(),
          color: Colors.black,
        ),
      ),
      body: FutureBuilder<List<MeetModel>>(
        future: MeetDB().getMeetsHistory(currentGang.gang.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return Center(
              child: CircularProgressIndicator(),
            );
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20, left: 20, bottom: 10),
                child: Row(
                  children: [
                    Text(
                      'Total meets: ${snapshot.data.length}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Spacer(),
                    Text(
                      'You arrived to: ${userArriveTo(context, snapshot.data)}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (ctx, i) {
                    final meet = snapshot.data[i];
                    if (meet.meetingAt.toDate().isAfter(DateTime.now()))
                      return Container();
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: WhiteRoundedCard(
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  meet.title,
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  meet.location,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  meet.moreInfo,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  DateFormat('dd/MM/yy HH:mm')
                                      .format(meet.meetingAt?.toDate()),
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              left: -10,
                              top: -10,
                              child: ClipOval(
                                child: Material(
                                  color: Colors.transparent,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (_) => EvetMembersArrivingList(
                                          currentGang: currentGang.gang,
                                          meet: MeetState(
                                            meet,
                                            currentGang.gang.id,
                                          ),
                                          isChangeable: false,
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.people_alt_outlined),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
