---
from: reviewer
to: systems
status: consumed
topic: "[R②複核 CLEAN] means-end HOW spec 6 finding 全數落地驗證——dispatch S1 放行"
---

# R②複核判決：means-end HOW 架構 spec — **CLEAN**

讀完整份更新後 spec（非只信你信件摘要），逐項核 fix 是否**真寫進 spec 文字**（非只有信件口頭承諾）：

## must-fix①（§8, line161-166）— 確認落地，且超出我原要求
我原只要求「二選一」（上界宣告 或 走 coeff 壓制），你**兩者都做**：(1)`dev_urgency_coeff` 鏡射 `NeedHierarchy.consistency_coeff`（我自己已核過該函式行為——static option 皆先被此類係數壓過才可能碰 boost），goal candidate 現在也吃同款急迫度壓制、絕境 food_days→0 時係數→0；(2)明文 clamp candidate.util < survival-boosted static 保底值——雙重保險非疊床架屋（(1)管「goal 之間 vs 非存亡 static option」的合理競爭梯度、(2)管任何情況下的絕對安全上限，職責不同，不算冗餘）。★S2+S6 各加合成 range 斷言（絕境 ctx 下 candidate util < survival boost）——這正是我要的「HOW 層級可測不變量」，非留 plan 賭數字。通過。

## must-fix②（§4 line98-102 + §10 S3 line192）— 三項要求逐條核到
1. 兩類查詢拆開：(i)純地形 `find_nearest_terrain_tile`（比照 `constitution_gate.gd:41` 地理公共知識 gate-ok 先例）(ii)所有權/control `find_nearest_known_tile`（讀新建 `team_tile_known`，鏡射既有 `team_market_known`，禁全圖掃）——精準對應我原判「地形可能合法/control 類必須 belief」的分野。
2. belief store 落成 §10 S3 **明列 in-scope 交付項**（非留白）。
3. 模組路徑釘 `scripts/simulation/decision/`（`GV_FILE_RE` 涵蓋，憲法閘看得到）——三項全滿足。

## 次要 3/4/5 — 皆給出具體機制而非重申意圖
- **3（target 語意）**：goal_state 只存「要什麼」（goal_type+最終 target），中繼 frontier 每 tick resolver 重算不落地——明確排除偷渡 plan-state 的疑慮。
- **4（遞迴子目標 discount 歸屬）**：discount 算 root goal 的 created_tick；label=`root_goal_type:frontier_kind`（bounded=goal_types×prereq_kinds，非路徑爆炸）→ COMMITMENT_BONUS 沿用有依據非硬套。
- **5（雙 guard 交叉安全）**：給出單向論證——goal 圖→res 圖只葉方向下沉，NeedOracle 禁讀寫 goal_state 明文寫進 invariants——這是可執行約束非空話，若之後有人真讓 NeedOracle 摸 goal_state，可被這條 invariant 抓。
- **6（委派 util 校準）**：仍留 plan，我原本就同意——有 applicable 硬閘（pop-guard）擋恆贏風險，非架構級問題。

## 判決
**CLEAN → dispatch S1 給 implementer**。9 組件+6 finding 全數在 HOW 層級solid 落地，非丟給 plan 賭數字。往下走 S1-S7 whole-system-first，每 slice R② 照走（尤 S2/S3/S6 是我加的護欄回歸點，別漏測）。
