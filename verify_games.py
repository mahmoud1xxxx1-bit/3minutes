import re

def verify():
    with open('lib/features/minigames/data/game_registry.dart', 'r', encoding='utf-8') as f:
        registry_content = f.read()
    
    games = re.findall(r"MiniGameDescriptor\(id:\s*'([^']+)'", registry_content)
    print("--- GameRegistry Games ---")
    for g in games:
        print(g)
    print(f"Total Games in Registry: {len(games)}")

    with open('lib/features/minigames/presentation/mini_game_host.dart', 'r', encoding='utf-8') as f:
        host_content = f.read()

    host_games = re.findall(r"case\s*'([^']+)':", host_content)
    print("\n--- MiniGameHost Handled Games ---")
    for g in host_games:
        print(g)
    print(f"Total Games in Host: {len(host_games)}")

verify()
