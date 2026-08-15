import os
import glob

views_dir = r"d:/WLAN Optimizer/ios/WlanOptimizerIOS/WlanOptimizerIOS/Views"

swift_files = []
for root, dirs, files in os.walk(views_dir):
    for file in files:
        if file.endswith(".swift"):
            swift_files.append(os.path.join(root, file))

for path in swift_files:
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    
    if "import UIKit" not in content:
        content = content.replace("import SwiftUI", "import SwiftUI\nimport UIKit")
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)
            
print("Injected import UIKit")
