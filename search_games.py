import os

root_dir = r"c:\Users\loved\3minutes\lib"
for root, dirs, files in os.walk(root_dir):
    for f in files:
        if f.endswith(".dart"):
            filepath = os.path.join(root, f)
            try:
                with open(filepath, "r", encoding="utf-8") as file:
                    content = file.read()
                    if "mole_strike" in content:
                        print(f"Found in {filepath}")
            except:
                pass
