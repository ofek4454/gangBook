import 'package:flutter/material.dart';

class AppTheme {
  Color _lightGreen = Color.fromARGB(255, 213, 235, 220);
  Color _lightGrey = Color.fromARGB(255, 164, 164, 164);
  Color _darkerGrey = Color.fromARGB(255, 119, 124, 135);

  ThemeData buildTheme() {
    return ThemeData(
      canvasColor: _lightGreen,
      primaryColor: _lightGreen,
      accentColor: _lightGrey,
      secondaryHeaderColor: _darkerGrey,
      hintColor: _lightGrey,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(
            color: _lightGrey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(
            color: _lightGreen,
          ),
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: _darkerGrey,
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        minWidth: 200,
        height: 40.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }
}
