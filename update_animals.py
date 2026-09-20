import re

animals_code = """
  static const _animals = <PathAnimal>[
    PathAnimal(id: 'rabbit', arName: 'الأرنب', foodName: 'جزر', foodEmoji: '🥕', wrong: [('موز','🍌'),('خس','🥬'),('تفاح','🍏'),('ذرة','🌽')]),
    PathAnimal(id: 'monkey', arName: 'القرد', foodName: 'موز', foodEmoji: '🍌', wrong: [('فول سوداني','🥜'),('تفاح','🍏'),('جزر','🥕'),('جوز','🌰')]),
    PathAnimal(id: 'lion', arName: 'الأسد', foodName: 'لحم', foodEmoji: '🥩', wrong: [('سمك','🐟'),('عظمة','🦴'),('عشب','🌿'),('دودة','🪱')]),
    PathAnimal(id: 'panda', arName: 'الباندا', foodName: 'خيزران', foodEmoji: '🎋', wrong: [('أوراق شجر','🍃'),('عشب','🌿'),('خس','🥬'),('موز','🍌')]),
    PathAnimal(id: 'cat', arName: 'القط', foodName: 'سمك', foodEmoji: '🐟', wrong: [('جبن','🧀'),('لحم','🥩'),('عظمة','🦴'),('جمبري','🦐')]),
    PathAnimal(id: 'dog', arName: 'الكلب', foodName: 'عظمة', foodEmoji: '🦴', wrong: [('لحم','🥩'),('سمك','🐟'),('جبن','🧀'),('حذاء','👞')]),
    PathAnimal(id: 'mouse', arName: 'الفأر', foodName: 'جبن', foodEmoji: '🧀', wrong: [('جوز','🌰'),('قمح','🌾'),('ذرة','🌽'),('فطر','🍄')]),
    PathAnimal(id: 'bear', arName: 'الدب', foodName: 'عسل', foodEmoji: '🍯', wrong: [('سمك','🐟'),('لحم','🥩'),('تفاح','🍏'),('فطر','🍄')]),
    PathAnimal(id: 'frog', arName: 'الضفدع', foodName: 'ذبابة', foodEmoji: '🪰', wrong: [('دودة','🪱'),('سمك','🐟'),('خس','🥬'),('زهرة','🌸')]),
    PathAnimal(id: 'turtle', arName: 'السلحفاة', foodName: 'خس', foodEmoji: '🥬', wrong: [('عشب','🌿'),('أوراق شجر','🍃'),('جزر','🥕'),('فطر','🍄')]),
    PathAnimal(id: 'bird', arName: 'العصفور', foodName: 'دودة', foodEmoji: '🪱', wrong: [('قمح','🌾'),('ذرة','🌽'),('ذبابة','🪰'),('زهرة','🌸')]),
    PathAnimal(id: 'horse', arName: 'الحصان', foodName: 'تفاح', foodEmoji: '🍏', wrong: [('جزر','🥕'),('قمح','🌾'),('عشب','🌿'),('ذرة','🌽')]),
    PathAnimal(id: 'cow', arName: 'البقرة', foodName: 'قمح', foodEmoji: '🌾', wrong: [('عشب','🌿'),('خس','🥬'),('ذرة','🌽'),('خيزران','🎋')]),
    PathAnimal(id: 'elephant', arName: 'الفيل', foodName: 'فول سوداني', foodEmoji: '🥜', wrong: [('موز','🍌'),('تفاح','🍏'),('أوراق شجر','🍃'),('خيزران','🎋')]),
    PathAnimal(id: 'squirrel', arName: 'السنجاب', foodName: 'جوز', foodEmoji: '🌰', wrong: [('فول سوداني','🥜'),('جبن','🧀'),('تفاح','🍏'),('ذرة','🌽')]),
    PathAnimal(id: 'penguin', arName: 'البطريق', foodName: 'جمبري', foodEmoji: '🦐', wrong: [('سمك','🐟'),('دودة','🪱'),('عشب','🌿'),('لحم','🥩')]),
    PathAnimal(id: 'bee', arName: 'النحلة', foodName: 'زهرة', foodEmoji: '🌸', wrong: [('عسل','🍯'),('ذبابة','🪰'),('أوراق شجر','🍃'),('دودة','🪱')]),
    PathAnimal(id: 'chicken', arName: 'الدجاجة', foodName: 'ذرة', foodEmoji: '🌽', wrong: [('قمح','🌾'),('دودة','🪱'),('عشب','🌿'),('خبز','🍞')]),
    PathAnimal(id: 'camel', arName: 'الجمل', foodName: 'صبار', foodEmoji: '🌵', wrong: [('عشب','🌿'),('خيزران','🎋'),('خس','🥬'),('تفاح','🍏')]),
    PathAnimal(id: 'snake', arName: 'الثعبان', foodName: 'بيضة', foodEmoji: '🥚', wrong: [('فأر','🐁'),('لحم','🥩'),('ضفدع','🐸'),('دودة','🪱')]),
    PathAnimal(id: 'koala', arName: 'الكوالا', foodName: 'أوراق شجر', foodEmoji: '🍃', wrong: [('خيزران','🎋'),('عشب','🌿'),('خس','🥬'),('موز','🍌')]),
    PathAnimal(id: 'duck', arName: 'البطة', foodName: 'خبز', foodEmoji: '🍞', wrong: [('سمك','🐟'),('ذرة','🌽'),('دودة','🪱'),('قمح','🌾')]),
    PathAnimal(id: 'bat', arName: 'الخفاش', foodName: 'عنب', foodEmoji: '🍇', wrong: [('تفاح','🍏'),('موز','🍌'),('ذبابة','🪰'),('دودة','🪱')]),
    PathAnimal(id: 'hedgehog', arName: 'القنفذ', foodName: 'فطر', foodEmoji: '🍄', wrong: [('جوز','🌰'),('تفاح','🍏'),('دودة','🪱'),('جبن','🧀')]),
  ];
"""

with open("lib/features/minigames/domain/path_rush_plan.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = re.sub(r'static const _animals = <PathAnimal>\[.*?\];', animals_code.strip(), content, flags=re.DOTALL)

content = re.sub(r'final travel = difficulty >= 2 \? 940 : difficulty == 1 \? 1120 : 1320;', r'final travel = 750; // Hard difficulty speed', content)

with open("lib/features/minigames/domain/path_rush_plan.dart", "w", encoding="utf-8") as f:
    f.write(content)
