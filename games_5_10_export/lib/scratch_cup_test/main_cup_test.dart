import 'package:flutter/material.dart';
import 'cup_game.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Arial',
      fontFamilyFallback: const ['Tahoma', 'sans-serif'],
    ),
    home: const Scaffold(
      backgroundColor: Color(0xFF0F172A), // Dark slate background
      body: Center(
        child: FollowTheCupGame(),
      ),
    ),
  ));
}
