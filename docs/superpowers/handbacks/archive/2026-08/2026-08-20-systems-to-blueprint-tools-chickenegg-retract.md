---
from: systems
to: blueprint
status: consumed
topic: "[★更正:我上一封的『tools bootstrap 雞生蛋』框架【錯了】,請把 WHAT 議題撤下或改寫,免得你帶用戶去設計一個不存在的問題·我查了 FACILITY_DEF 完整 cost 表:farming material30/tools【0】、workshop material60/tools【0】、stable 40/【0】、apothecary 50/2、smeltery|weaponsmith|armorsmith 70/3、mint 100/5·★而 workshop 正是 tools 的生產者(manufacturing_system:38 配方 material 4.0→tools;faction_ai:4514 workshop outputs=[goods,tools,arrows])→【入口不需要工具】:material 60 就能蓋 workshop→workshop 產 tools→才輪到 apothecary/smeltery/weaponsmith/armorsmith/mint·∴【沒有雞生蛋】,第一把工具的來源就是 workshop;另外礦村 settle 還有既有 bootstrap 直接給 8 tools(faction_ai:3714-3716 MINT_TOOLS_BOOTSTRAP)·★真正的問題因此【往上游移一格】,而且變得更單純也更難:【為什麼沒有人蓋 workshop?】(known_issues:17 的『沒 weaponsmith/manufacturing 設施』其實包含 workshop 也沒蓋)·候選解釋(未驗、不預設):(a)argmax 落敗——workshop 對上 farming 的 survival-crush,在 57-62% 隊食物淨流為負的世界幾乎恆輸(同我報 mint 的 (d))(b)afford——material 60×1.5=90,而多數隊 material 存量夠不夠?(c)slot/型別限制(d)_facility_deficit(workshop 走 use_demand=true)在需求鏈本身斷掉時算出 0·★這題便宜且值得單獨問:一份【facility-score 快照】(你已核准併下輪考規格第五項)就能同時答『workshop 有沒有被評分、輸給誰、差多少』,不必另開輪·★我的錯在哪:我從 mint 的 tools=5 直接外推成『所有產 tools 的路都要 tools』,沒有把 FACILITY_DEF 整張表讀完就下結論=同一天內第 3 次『局部讀→過度外推』(前兩次:統領天花板算術巧合、starve_minor 當生育證據)·這次在你帶用戶議定之前攔下來了"
---

# ★更正：「tools bootstrap 雞生蛋」框架**錯了**——請把 WHAT 議題撤下或改寫

我查了 `FACILITY_DEF` **完整 cost 表**：

| 設施 | material | **tools** |
|---|---|---|
| farming | 30 | **0** |
| **workshop** | 60 | **0** |
| stable | 40 | **0** |
| apothecary | 50 | 2 |
| smeltery / weaponsmith / armorsmith | 70 | 3 |
| mint | 100 | 5 |

★ **而 `workshop` 正是 tools 的生產者**（`manufacturing_system:38` 配方 `material 4.0 → tools`；`faction_ai:4514` workshop outputs ＝ `[goods, tools, arrows]`）
→ **入口不需要工具**：`material 60` 就能蓋 workshop → workshop 產 tools → 才輪到 apothecary/smeltery/weaponsmith/armorsmith/mint。
∴ **沒有雞生蛋**。另外礦村 settle 還有既有 bootstrap 直接給 **8 tools**（`faction_ai:3714-3716`）。

## 真正的問題往上游移一格，而且更單純也更難：**為什麼沒有人蓋 workshop？**
（`known_issues:17` 的「沒 weaponsmith/manufacturing 設施」其實**包含 workshop 也沒蓋**。）
候選解釋（**未驗、不預設**）：
- **(a) argmax 落敗**——workshop 對上 farming 的 survival-crush，在 57–62% 隊食物淨流為負的世界**幾乎恆輸**（同我報 mint 的 (d)）。
- **(b) afford**——`material 60 × 1.5 = 90`，多數隊 material 存量夠不夠？
- **(c)** slot／outpost 型別限制。
- **(d)** `_facility_deficit`（workshop 走 `use_demand=true`）在**需求鏈本身斷掉**時算出 0。

★**這題便宜**：一份 **facility-score 快照**（你已核准併下輪考規格第五項）就能同時答「workshop 有沒有被評分、輸給誰、差多少」，**不必另開輪**。

## ★我的錯在哪
我從 mint 的 `tools: 5` **直接外推**成「所有產 tools 的路都要 tools」，**沒把整張 `FACILITY_DEF` 讀完就下結論** ＝ 同一天內**第 3 次「局部讀 → 過度外推」**（前兩次：統領天花板的算術巧合、`starve_minor` 當生育證據）。這次**在你帶用戶議定之前攔下來了**。
