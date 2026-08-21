import re

with open('test/widget_test.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('gameCount: 8', 'gameCount: 4')
content = content.replace('count: 8', 'count: 4')
content = content.replace('length, 8', 'length, 4')
content = content.replace('completedGames: 8', 'completedGames: 4')
content = content.replace('totalScore: 800', 'totalScore: 400')
content = content.replace('accuracyTotal: 8', 'accuracyTotal: 4')

# Replace completedGames: 5 in the settlement test
content = content.replace('completedGames: 5,', 'completedGames: 2,')
content = content.replace('totalScore: 500,', 'totalScore: 200,')
content = content.replace('accuracyTotal: 5,', 'accuracyTotal: 2,')

old_test_pattern = r"test\('outcome prioritizes progress before score', \(\) \{.*?\}\);"
new_test = """test('outcome prioritizes progress before score', () {
    const playerA = MatchProgress(
      completedGames: 4,
      totalScore: 10,
      accuracyTotal: 4,
      mistakes: 0,
      elapsedMs: 50000,
    );
    const playerB = MatchProgress(
      completedGames: 2,
      totalScore: 9999,
      accuracyTotal: 4,
      mistakes: 0,
      elapsedMs: 1000,
    );
    expect(
      MatchOutcomeResolver.compare(playerA: playerA, playerB: playerB, gameCount: 4),
      MatchOutcome.playerA,
    );
  });"""
content = re.sub(old_test_pattern, new_test, content, flags=re.DOTALL)

with open('test/widget_test.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
