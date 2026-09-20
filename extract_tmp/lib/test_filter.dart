import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey,
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/onet_full/tile_1.png', width: 100, height: 100),
              const SizedBox(width: 20),
              ColorFiltered(
                colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.hue),
                child: Image.asset('assets/images/onet_full/tile_1.png', width: 100, height: 100),
              ),
              const SizedBox(width: 20),
              ColorFiltered(
                colorFilter: const ColorFilter.mode(Colors.red, BlendMode.hue),
                child: Image.asset('assets/images/onet_full/tile_1.png', width: 100, height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
