import 'package:flutter/material.dart';
import 'mole_game.dart';

void main() {
  runApp(const MoleApp());
}

class MoleApp extends StatelessWidget {
  const MoleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Arial'),
      home: const Scaffold(
        backgroundColor: Color(0xFF166534), // Dark lush grass
        body: Center(
          child: SizedBox(
            width: 450,
            height: 900,
            child: SafeArea(child: MoleTestScreen()),
          ),
        ),
      ),
    );
  }
}
