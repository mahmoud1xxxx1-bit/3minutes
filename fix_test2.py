code = '''import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TestAnimalsScreen(),
  ));
}

class TestAnimalsScreen extends StatelessWidget {
  const TestAnimalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D5D30), 
      appBar: AppBar(title: const Text('Test 15 Animals (Perfect 60x75 Tiles)')),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Wrap(
              spacing: 100.0,
              runSpacing: 100.0,
              children: List.generate(15, (index) {
                return Container(
                  width: 60,
                  height: 75,
                  child: Image.asset(
                    'assets/images/onet_full/tile_.png',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
'''
with open('lib/test_animals.dart', 'w', encoding='utf-8') as f:
    f.write(code)
