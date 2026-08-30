import os
import shutil

src = r"C:\Users\loved\Desktop\temp_games_11"
dest = r"c:\Users\loved\3minutes\lib\features\minigames"
assets_dest = r"c:\Users\loved\3minutes\assets\minigames"

games = [
    "find_differences", "follow_the_cup", "key_escape", "level_devil",
    "mirror_control", "mole_strike", "ninja_slice", "onet_connect",
    "path_rush", "traffic_loop", "hidden_pigeon"
]

# 1. Clean up old presentation files that are not host-related
pres_dir = os.path.join(dest, "presentation")
for item in os.listdir(pres_dir):
    item_path = os.path.join(pres_dir, item)
    if os.path.isfile(item_path):
        if "game" in item and "host" not in item:
            os.remove(item_path)

# 2. Copy games presentation and domain files
for game in games:
    # Presentation
    game_pres_src = os.path.join(src, game, "presentation")
    if os.path.exists(game_pres_src):
        game_pres_dest = os.path.join(dest, "presentation", game)
        if os.path.exists(game_pres_dest):
            shutil.rmtree(game_pres_dest)
        shutil.copytree(game_pres_src, game_pres_dest)
    
    # Domain
    game_domain_src = os.path.join(src, game, "domain")
    if os.path.exists(game_domain_src):
        game_domain_dest = os.path.join(dest, "domain")
        for f in os.listdir(game_domain_src):
            shutil.copy(os.path.join(game_domain_src, f), os.path.join(game_domain_dest, f))

# 3. Copy Shared Core
shared_pres_src = os.path.join(src, "shared_core", "presentation")
if os.path.exists(shared_pres_src):
    shared_pres_dest = os.path.join(dest, "presentation", "shared")
    if os.path.exists(shared_pres_dest):
        shutil.rmtree(shared_pres_dest)
    shutil.copytree(shared_pres_src, shared_pres_dest)

shared_domain_src = os.path.join(src, "shared_core", "domain")
if os.path.exists(shared_domain_src):
    shared_domain_dest = os.path.join(dest, "domain")
    for f in os.listdir(shared_domain_src):
        shutil.copy(os.path.join(shared_domain_src, f), os.path.join(shared_domain_dest, f))

rng_src = os.path.join(src, "shared_core", "core", "deterministic_rng.dart")
if os.path.exists(rng_src):
    rng_dest_dir = r"c:\Users\loved\3minutes\lib\core\random"
    os.makedirs(rng_dest_dir, exist_ok=True)
    shutil.copy(rng_src, os.path.join(rng_dest_dir, "deterministic_rng.dart"))

# 4. Copy Assets
for game in games:
    game_assets_src = os.path.join(src, game, "assets")
    if os.path.exists(game_assets_src):
        game_assets_dest = os.path.join(r"c:\Users\loved\3minutes\assets", game)
        if not os.path.exists(game_assets_dest):
            shutil.copytree(game_assets_src, game_assets_dest)

print("Integration complete!")
