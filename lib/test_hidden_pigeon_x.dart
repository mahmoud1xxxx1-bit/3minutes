import 'package:flutter/material.dart';
import 'features/minigames/domain/mini_game_contract.dart';
import 'features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart';

void main() {
  runApp(const HiddenPigeonTesterApp());
}

class HiddenPigeonTesterApp extends StatelessWidget {
  const HiddenPigeonTesterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hidden Pigeon X1-X30 Tester',
      theme: ThemeData(useMaterial3: true),
      home: const XGridScreen(),
    );
  }
}

class XGridScreen extends StatefulWidget {
  const XGridScreen({super.key});

  @override
  State<XGridScreen> createState() => _XGridScreenState();
}

class _XGridScreenState extends State<XGridScreen> {
  int? _playingX;

  void _playX(int xId) {
    setState(() {
      _playingX = xId;
    });
  }

  void _onComplete(MiniGameResult result) {
    setState(() {
      _playingX = null;
    });
    // Show a small dialog with the result
  }

  @override
  Widget build(BuildContext context) {
    if (_playingX != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              HiddenPigeonGame(
                config: MiniGameConfig(seed: _playingX!, difficulty: 2),
                onComplete: _onComplete,
              ),
              Positioned(
                top: 16, left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                  onPressed: () => setState(() => _playingX = null),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E272E),
      appBar: AppBar(
        title: const Text('Hidden Pigeon - X Packs (X1 to X30)', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2C3E50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1.0,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 30,
          itemBuilder: (context, index) {
            final xId = index + 1;
            return GestureDetector(
              onTap: () => _playX(xId),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4))
                  ],
                ),
                child: Center(
                  child: Text(
                    'X',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
