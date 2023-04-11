import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gangbook/models/gang_model.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/screens/root/root.dart';
import 'package:gangbook/services/meets_db.dart';
import 'package:intl/intl.dart';

class ScheduleNewMeetingScreen extends StatefulWidget {
  final GangModel currentGang;
  final UserModel user;

  ScheduleNewMeetingScreen(this.currentGang, this.user);

  @override
  _ScheduleNewMeetingScreenState createState() =>
      _ScheduleNewMeetingScreenState();
}

class _ScheduleNewMeetingScreenState extends State<ScheduleNewMeetingScreen> {
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final timeController = TextEditingController();
  final dateController = TextEditingController();
  final moreInfoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime meetingDate;
  TimeOfDay meetingTime;
  File meetingImage;
  bool isLoading = false;

  Future<void> _schedule() async {
    final isValidate = _formKey.currentState.validate();
    if (!isValidate) return;
    setState(() {
      isLoading = true;
    });
    try {
      DateTime meetingAt = DateTime(
        meetingDate.year,
        meetingDate.month,
        meetingDate.day,
        meetingTime.hour,
        meetingTime.minute,
      );
      final userGangMember = widget.currentGang.members
          .firstWhere((member) => member.uid == widget.user.uid);
      final result = await MeetDB().setNewMeet(
        user: widget.user,
        title: titleController.text,
        location: locationController.text,
        moreInfo: moreInfoController.text,
        meetingAt: Timestamp.fromDate(meetingAt),
        gang: widget.currentGang,
        createBy: userGangMember,
      );
      if (result == 'success') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => RootScreen(),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Someting went wrong, please try again."),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      }
    } catch (error) {
      print(error);
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget _buildCustomTextField({
    BuildContext context,
    IconData icon,
    String label,
    TextEditingController controller,
    bool needValidation = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
        hintStyle: TextStyle(color: Colors.red),
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).secondaryHeaderColor,
        ),
      ),
      validator: !needValidation
          ? null
          : (val) {
              if (val.isEmpty || val == null) {
                return 'this field is required';
              }
              return null;
            },
    );
  }

  _buildCustomTimePicker(BuildContext context) {
    return TextFormField(
      controller: timeController,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        hintText: 'Select time',
        labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
        hintStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
        prefixIcon: Icon(
          Icons.access_time,
          color: Theme.of(context).secondaryHeaderColor,
        ),
      ),
      validator: (val) {
        if (val.isEmpty || val == null) {
          return 'this field is required';
        }
        return null;
      },
      onTap: () => showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      ).then((pickedTime) {
        if (pickedTime != null) {
          meetingTime = pickedTime;
          timeController.text = pickedTime.format(context);
        }
      }),
    );
  }

  _buildCustomDatePicker(BuildContext context) {
    return TextFormField(
      controller: dateController,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        hintText: 'Select Date',
        labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
        hintStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
        prefixIcon: Icon(
          Icons.calendar_today_outlined,
          color: Theme.of(context).secondaryHeaderColor,
        ),
      ),
      validator: (val) {
        if (val.isEmpty || val == null) {
          return 'this field is required';
        }
        return null;
      },
      onTap: () => showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 14)),
        firstDate: DateTime.now(),
      ).then((pickedDate) {
        if (pickedDate != null) {
          meetingDate = pickedDate;
          dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildCustomTextField(
                context: context,
                label: 'Meeting title',
                icon: Icons.local_fire_department,
                controller: titleController,
              ),
              SizedBox(height: 15),
              _buildCustomTextField(
                context: context,
                label: 'location',
                icon: Icons.location_on_outlined,
                controller: locationController,
              ),
              SizedBox(height: 15),
              _buildCustomDatePicker(context),
              SizedBox(height: 15),
              _buildCustomTimePicker(context),
              SizedBox(height: 15),
              _buildCustomTextField(
                context: context,
                label: 'more...',
                icon: Icons.text_fields_rounded,
                controller: moreInfoController,
                needValidation: false,
              ),
              TextButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                },
                child: Text('unfocus'),
              ),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed: () => _schedule(),
                      child: Text(
                        'Schedule',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
