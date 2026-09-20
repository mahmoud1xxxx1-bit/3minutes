import 'package:flutter/material.dart';
import 'html_canvas.dart';
import 'puzzle_model.dart';
import 'puzzles/puzzle_01.dart';
import 'puzzles/puzzle_02.dart';
import 'puzzles/puzzle_03.dart';
import 'puzzles/puzzle_04.dart';
import 'puzzles/puzzle_05.dart';
import 'puzzles/puzzle_06.dart';
import 'puzzles/puzzle_07.dart';
import 'puzzles/puzzle_08.dart';
import 'puzzles/puzzle_09.dart';
import 'puzzles/puzzle_10.dart';
import 'puzzles/puzzle_11.dart';
import 'puzzles/puzzle_12.dart';
import 'puzzles/puzzle_13.dart';
import 'puzzles/puzzle_14.dart';
import 'puzzles/puzzle_15.dart';
import 'puzzles/puzzle_16.dart';
import 'puzzles/puzzle_17.dart';
import 'puzzles/puzzle_18.dart';
import 'puzzles/puzzle_19.dart';
import 'puzzles/puzzle_20.dart';
import 'puzzles/puzzle_21.dart';
import 'puzzles/puzzle_22.dart';
import 'puzzles/puzzle_23.dart';
import 'puzzles/puzzle_24.dart';
import 'puzzles/puzzle_25.dart';
import 'puzzles/puzzle_26.dart';
import 'puzzles/puzzle_27.dart';
import 'puzzles/puzzle_28.dart';
import 'puzzles/puzzle_29.dart';
import 'puzzles/puzzle_30.dart';

void main() {
  runApp(const SpotTheDifferenceApp());
}

class SpotTheDifferenceApp extends StatelessWidget {
  const SpotTheDifferenceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spot the Difference',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050914),
      ),
      home: const PuzzleScreen(),
    );
  }
}

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({Key? key}) : super(key: key);

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  Set<String> foundIds = {};
  int mistakes = 0;
  int currentPuzzleIndex = 0;
  
  final List<PuzzleDefinition> puzzles = [
    Puzzle01(),
    Puzzle02(),
    Puzzle03(),
    Puzzle04(),
    Puzzle05(),
    Puzzle06(),
    Puzzle07(),
    Puzzle08(),
    Puzzle09(),
    Puzzle10(),
    Puzzle11(),
    Puzzle12(),
    Puzzle13(),
    Puzzle14(),
    Puzzle15(),
    Puzzle16(),
    Puzzle17(),
    Puzzle18(),
    Puzzle19(),
    Puzzle20(),
    Puzzle21(),
    Puzzle22(),
    Puzzle23(),
    Puzzle24(),
    Puzzle25(),
    Puzzle26(),
    Puzzle27(),
    Puzzle28(),
    Puzzle29(),
    Puzzle30()
  ];

  void _handleTap(Offset localPosition, Size boardSize, bool isBoardB) {
    double scaleX = 800 / boardSize.width;
    double scaleY = 600 / boardSize.height;
    Offset logicalPos = Offset(localPosition.dx * scaleX, localPosition.dy * scaleY);

    var p = puzzles[currentPuzzleIndex];
    String? hitId;
    print('Tapped at ' + logicalPos.toString());
    // First, prioritize hitboxes that haven't been found yet
    for (var diff in p.differences) {
      if (diff.hitBox.inflate(40).contains(logicalPos) && !foundIds.contains(diff.id)) {
        hitId = diff.id;
        break;
      }
    }
    
    // If not found, check if they tapped an already found one (to avoid counting as mistake)
    if (hitId == null) {
      for (var diff in p.differences) {
        if (diff.hitBox.inflate(40).contains(logicalPos)) {
          hitId = diff.id;
          break;
        }
      }
    }

    if (hitId != null && !foundIds.contains(hitId)) {
      setState(() {
        foundIds.add(hitId!);
          print('Found ' + hitId! + ' total ' + foundIds.length.toString());
      });
      if (foundIds.length == 5) {
        _showWinDialog();
      }
    } else {
      setState(() {
        mistakes++;
      });
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF12233f),
        title: const Text("أحسنت!", textAlign: TextAlign.center, style: TextStyle(color: Colors.white), textDirection: TextDirection.rtl),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("5/5", style: TextStyle(fontSize: 38, color: Color(0xFF0cc373), fontWeight: FontWeight.bold)),
            Text("الأخطاء: $mistakes", style: const TextStyle(color: Colors.white, fontSize: 18), textDirection: TextDirection.rtl),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              key: const Key('next_round'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0cc373)),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  foundIds.clear();
                  mistakes = 0;
                  if (currentPuzzleIndex < puzzles.length - 1) {
                    currentPuzzleIndex++;
                  } else {
                    currentPuzzleIndex = 0; // wrap around
                  }
                });
              },
              child: const Text("المستوى التالي", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1),
            radius: 1.5,
            colors: [Color(0xFF1b2c49), Color(0xFF081322), Color(0xFF03060c)],
            stops: [0.0, 0.52, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPill("${foundIds.length}/5", "الفروقات"),
                    const SizedBox(width: 10),
                    _buildPill("$mistakes", "الأخطاء"),
                    const SizedBox(width: 10),
                    _buildPill("لغز ${currentPuzzleIndex+1}", "المستوى"),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text("اكتشف 5 فروقات", style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                      bool isPortrait = constraints.maxWidth < constraints.maxHeight;
                      return Flex(
                        direction: isPortrait ? Axis.vertical : Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: _buildBoard(false)),
                          SizedBox(width: isPortrait ? 0 : 10, height: isPortrait ? 10 : 0),
                          Expanded(child: _buildBoard(true)),
                        ],
                      );
                    },
                  ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPill(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0b1528),
        border: Border.all(color: const Color(0xFF2b4667)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Color(0xFF72edff), fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Color(0xFF91a7c1), fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBoard(bool isBoardB) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0a1120),
          border: Border.all(color: const Color(0xFF315277)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10))],
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              key: Key(isBoardB ? 'boardB' : 'boardA'),
              onTapDown: (details) => _handleTap(details.localPosition, constraints.biggest, isBoardB),
              child: CustomPaint(
                size: constraints.biggest,
                painter: DynamicPuzzlePainter(
                  isBoardB: isBoardB,
                  foundIds: foundIds,
                  puzzle: puzzles[currentPuzzleIndex],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DynamicPuzzlePainter extends CustomPainter {
  final bool isBoardB;
  final Set<String> foundIds;
  final PuzzleDefinition puzzle;

  DynamicPuzzlePainter({required this.isBoardB, required this.foundIds, required this.puzzle});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 800, size.height / 600);
    
    HtmlCanvas c = HtmlCanvas(canvas, size);
    
    // Draw Base
    puzzle.drawBaseScene(c);
    
    // Draw Differences
    if (isBoardB) {
      for (var diff in puzzle.differences) {
        c.save();
        diff.draw(c);
        c.restore();
      }
    }
    
    // Draw found marks
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    final markPaint = Paint()
      ..color = const Color(0xFF00FF00) // Bright pure green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    for (String id in foundIds) {
      for (var diff in puzzle.differences) {
        if (diff.id == id) {
          canvas.drawCircle(diff.mark, 25, shadowPaint);
          canvas.drawCircle(diff.mark, 25, markPaint);
        }
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DynamicPuzzlePainter oldDelegate) {
    return oldDelegate.foundIds.length != foundIds.length ||
           oldDelegate.puzzle.id != puzzle.id;
  }
}
