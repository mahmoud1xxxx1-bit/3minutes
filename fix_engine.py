import re

engine_path = r"c:\Users\loved\3minutes\lib\features\minigames\domain\mini_game_engine.dart"
with open(engine_path, "r", encoding="utf-8") as f:
    content = f.read()

new_engines = """  static const Map<String, MiniGameEngine> byGameId = {
    'path_rush': MiniGameEngine.choice,
    'mole_strike': MiniGameEngine.target,
    'find_differences': MiniGameEngine.target,
    'follow_the_cup': MiniGameEngine.sequence,
    'key_escape': MiniGameEngine.choice,
    'level_devil': MiniGameEngine.target,
    'mirror_control': MiniGameEngine.target,
    'ninja_slice': MiniGameEngine.target,
    'onet_connect': MiniGameEngine.choice,
    'traffic_loop': MiniGameEngine.choice,
    'hidden_pigeon': MiniGameEngine.target,
  };"""

content = re.sub(r"static const Map<String, MiniGameEngine> byGameId = \{.*?\};", new_engines, content, flags=re.DOTALL)

with open(engine_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Engine Registry updated")
