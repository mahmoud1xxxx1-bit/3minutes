import re

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Make sure MiniGameCopy is imported
if "import '../../../../minigames_VBN/presentation/mini_game_copy.dart';" not in content:
    content = content.replace(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport '../../../../minigames_VBN/presentation/mini_game_copy.dart';"
    )

# Replace the counter Container with a Column containing the counter and the instruction
old_counter_block = """                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24, height: 24,
                        child: CustomPaint(painter: PigeonPainter(Colors.blueAccent)),
                      ),
                      const SizedBox(width: 8),
                      Text('/10', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2C3E50))),
                    ],
                  ),
                ),"""

new_counter_block = """                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24, height: 24,
                            child: CustomPaint(painter: PigeonPainter(Colors.white, isSolid: true)),
                          ),
                          const SizedBox(width: 8),
                          Text('/10', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        MiniGameCopy.fromContext(context).hiddenPigeonInstruction,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),"""

# Perform replacement
content = content.replace(old_counter_block, new_counter_block)

# Just in case there are minor whitespace differences, use regex fallback
if "MiniGameCopy.fromContext" not in content:
    content = re.sub(
        r"Container\(\s*padding: const EdgeInsets.symmetric\(horizontal: 20, vertical: 10\).*?Text\('\$\{\_foundPigeons\.length\}/10'.*?\),.*?\]\s*,\s*\)\s*,\s*\),",
        new_counter_block + ",",
        content,
        flags=re.DOTALL
    )

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "w", encoding="utf-8") as f:
    f.write(content)
