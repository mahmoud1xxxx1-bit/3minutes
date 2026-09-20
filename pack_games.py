import os
import shutil
import hashlib

source_dir = r"c:\Users\loved\3minutes"
staging_dir = r"c:\Users\loved\Desktop\games_11_original_complete"

if os.path.exists(staging_dir):
    shutil.rmtree(staging_dir)
os.makedirs(staging_dir)

games = [
    "find_differences", "follow_the_cup", "key_escape", "level_devil",
    "mirror_control", "mole_strike", "ninja_slice", "onet_connect",
    "path_rush", "traffic_loop", "hidden_pigeon"
]

dart_files_count = 0
assets_files_count = 0

# 1. Copy each game's presentation folder
for game in games:
    game_src = os.path.join(source_dir, "lib", "features", "minigames", "presentation", game)
    game_dst = os.path.join(staging_dir, game, "presentation")
    if os.path.exists(game_src):
        shutil.copytree(game_src, game_dst)
        for root, _, files in os.walk(game_dst):
            for f in files:
                if f.endswith('.dart'):
                    dart_files_count += 1

# 2. Copy domain plans for each game
domain_src = os.path.join(source_dir, "lib", "features", "minigames", "domain")
if os.path.exists(domain_src):
    for game in games:
        # e.g. path_rush_plan.dart
        plan_file = f"{game}_plan.dart"
        src_path = os.path.join(domain_src, plan_file)
        if os.path.exists(src_path):
            dst_dir = os.path.join(staging_dir, game, "domain")
            os.makedirs(dst_dir, exist_ok=True)
            shutil.copy(src_path, os.path.join(dst_dir, plan_file))
            dart_files_count += 1

# 3. Copy shared core/minigame files (UnifiedGameScaffold, MinigameEnvironment, etc.)
shared_src = os.path.join(source_dir, "lib", "features", "minigames", "presentation", "shared")
shared_dst = os.path.join(staging_dir, "shared_core", "presentation")
if os.path.exists(shared_src):
    shutil.copytree(shared_src, shared_dst)
    for root, _, files in os.walk(shared_dst):
        for f in files:
            if f.endswith('.dart'):
                dart_files_count += 1

# Domain core
for core_file in ["mini_game_contract.dart", "mini_game_engine.dart"]:
    src_path = os.path.join(domain_src, core_file)
    if os.path.exists(src_path):
        dst_dir = os.path.join(staging_dir, "shared_core", "domain")
        os.makedirs(dst_dir, exist_ok=True)
        shutil.copy(src_path, os.path.join(dst_dir, core_file))
        dart_files_count += 1

# DeterministicRng
rng_src = os.path.join(source_dir, "lib", "core", "random", "deterministic_rng.dart")
if os.path.exists(rng_src):
    dst_dir = os.path.join(staging_dir, "shared_core", "core")
    os.makedirs(dst_dir, exist_ok=True)
    shutil.copy(rng_src, os.path.join(dst_dir, "deterministic_rng.dart"))
    dart_files_count += 1

# 4. Copy Assets
assets_src = os.path.join(source_dir, "assets")
for game in games:
    game_assets_src = os.path.join(assets_src, game)
    if os.path.exists(game_assets_src):
        game_assets_dst = os.path.join(staging_dir, game, "assets")
        shutil.copytree(game_assets_src, game_assets_dst)
        for root, _, files in os.walk(game_assets_dst):
            for f in files:
                assets_files_count += 1

# 5. Create GAMES_11_HANDOFF.md
markdown = """# GAMES_11_HANDOFF

This archive contains the 11 completed minigames. Each game is contained within its own folder with its respective domain (plan) and presentation (UI) files. A shared_core folder contains the unified game scaffold, environment, and deterministic RNG used by all games.

## 1. Find Differences
- **ID:** ind_differences
- **Run File:** presentation/find_differences_game.dart
- **Orientation:** Portrait/Landscape
- **Original Timer:** Yes
- **Uses Seed:** Yes
- **Dependencies:** None

## 2. Follow The Cup
- **ID:** ollow_the_cup
- **Run File:** presentation/follow_the_cup_game.dart
- **Orientation:** Portrait/Landscape
- **Original Timer:** No (Turn-based)
- **Uses Seed:** Yes
- **Dependencies:** None

## 3. Key Escape
- **ID:** key_escape
- **Run File:** presentation/key_escape_game.dart
- **Orientation:** Portrait/Landscape
- **Original Timer:** No
- **Uses Seed:** Yes
- **Dependencies:** None

## 4. Level Devil
- **ID:** level_devil
- **Run File:** presentation/level_devil_game.dart
- **Orientation:** Portrait/Landscape
- **Original Timer:** No
- **Uses Seed:** Yes
- **Dependencies:** None

## 5. Mirror Control
- **ID:** mirror_control
- **Run File:** presentation/mirror_control_game.dart
- **Orientation:** Portrait/Landscape
- **Original Timer:** Yes
- **Uses Seed:** Yes
- **Dependencies:** None

## 6. Mole Strike
- **ID:** mole_strike
- **Run File:** presentation/mole_strike_game.dart
- **Orientation:** Portrait/Landscape
- **Original Timer:** Yes
- **Uses Seed:** Yes
- **Dependencies:** None

## 7. Ninja Slice
- **ID:** 
inja_slice
- **Run File:** presentation/ninja_slice_game.dart
- **Orientation:** Portrait/Landscape
- **Original Timer:** Yes
- **Uses Seed:** Yes
- **Dependencies:** None

## 8. Onet Connect
- **ID:** onet_connect
- **Run File:** presentation/onet_connect_game.dart
- **Orientation:** Portrait/Landscape
- **Original Timer:** Yes
- **Uses Seed:** Yes
- **Dependencies:** None

## 9. Path Rush
- **ID:** path_rush
- **Run File:** presentation/path_rush_game.dart
- **Orientation:** Portrait/Landscape
- **Original Timer:** Yes
- **Uses Seed:** Yes
- **Dependencies:** None

## 10. Traffic Loop
- **ID:** 	raffic_loop
- **Run File:** presentation/traffic_loop_game.dart
- **Orientation:** Portrait/Landscape
- **Original Timer:** Yes
- **Uses Seed:** Yes
- **Dependencies:** None

## 11. Hidden Pigeon
- **ID:** hidden_pigeon
- **Run File:** presentation/hidden_pigeon_game.dart
- **Orientation:** Portrait/Landscape
- **Original Timer:** No
- **Uses Seed:** Yes
- **Dependencies:** None
"""

with open(os.path.join(staging_dir, "GAMES_11_HANDOFF.md"), "w", encoding="utf-8") as f:
    f.write(markdown)

# 6. Zip everything
import zipfile
zip_path = r"c:\Users\loved\Desktop\games_11_original_complete.zip"
with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
    for root, _, files in os.walk(staging_dir):
        for file in files:
            file_path = os.path.join(root, file)
            zipf.write(file_path, os.path.relpath(file_path, staging_dir))

# 7. Get File Stats
size_mb = os.path.getsize(zip_path) / (1024 * 1024)

# SHA256
sha256_hash = hashlib.sha256()
with open(zip_path,"rb") as f:
    for byte_block in iter(lambda: f.read(4096),b""):
        sha256_hash.update(byte_block)
        
sha = sha256_hash.hexdigest()

print(f"PATH: {zip_path}")
print(f"SIZE: {size_mb:.2f} MB")
print(f"DART: {dart_files_count}")
print(f"ASSETS: {assets_files_count}")
print(f"SHA256: {sha}")

# Cleanup staging
shutil.rmtree(staging_dir)
