import re

copy_path = r"c:\Users\loved\3minutes\lib\features\minigames\presentation\mini_game_copy.dart"
with open(copy_path, "r", encoding="utf-8") as f:
    content = f.read()

new_titles = """  String title(String gameId) => switch (gameId) {
        'find_differences' => isArabic ? 'البحث عن الفروق' : 'Find Differences',
        'follow_the_cup' => isArabic ? 'تتبع الكوب' : 'Follow the Cup',
        'key_escape' => isArabic ? 'مفتاح الهروب' : 'Key Escape',
        'level_devil' => isArabic ? 'مستوى الشيطان' : 'Level Devil',
        'mirror_control' => isArabic ? 'تحكم المرايا' : 'Mirror Control',
        'mole_strike' => isArabic ? 'ضرب السنجاب' : 'Mole Strike',
        'ninja_slice' => isArabic ? 'نينجا الفواكه' : 'Ninja Slice',
        'onet_connect' => isArabic ? 'توصيل الاشكال' : 'Onet Connect',
        'path_rush' => isArabic ? 'اختيار المسار' : 'Path Rush',
        'traffic_loop' => isArabic ? 'المرور المعقد' : 'Traffic Loop',
        'hidden_pigeon' => isArabic ? 'حمامة متخفية' : 'Hidden Pigeon',
        _ => isArabic ? 'لعبة مصغرة' : 'Mini-Game',
      };"""

content = re.sub(r"  String title\(String gameId\) => switch \(gameId\) \{.*?\};", new_titles, content, flags=re.DOTALL)

with open(copy_path, "w", encoding="utf-8") as f:
    f.write(content)

print("MiniGameCopy updated")
