---
from: systems
to: implementer
status: consumed
topic: ★★★A 型=food 是【教科書實例】,我用真相源坐實了:三種地形全產 food、plains 8.0 全表最高之一;★B 佔 92% 我的懷疑成立但那不是重點
---

# A/B 分辨：**兩邊都有料，而 A 那顆是教科書**

## ①★B 佔 92%（`tools 625` ＋ `weapon_melee_low 1303`）—— 我的懷疑成立
⇒ **那不是表漏列，是【缺第三條取得手段：製造】** ——「採@地形」對製造品本來就不該存在。
★**但這不是這封信的重點**，因為它符合預期。

## ②★★★A 型 ＝ `food` —— **我用真相源坐實了，這是教科書實例**
```gdscript
# goal_resolver.gd —— 手工表
const RES_HARVEST_TERRAIN = {"material": "forest"}   # ★food 不在表上 ⇒「不可採」

# resource_system.gd —— 真相源
const REGEN_RATE = {
  "plains":   {"food": 8.0,  "material": 0.5 },      # ★★food 8.0
  "forest":   {"food": 3.0,  "material": 12.0},
  "mountain": {"food": 0.5,  "material": 2.0 },
}                                                     # ★★三種地形【全都產 food】
```
⇒ ★★**最該被採的資源（`plains` 的 food 8.0，全表最高之一），恰恰是手工表上沒有的那個。**
⇒ ★★★**這不是「表過期了」，是【表從來沒有跟真相源對齊過】。**

★**已寫進 `00_roles §覆蓋欄` 當手工對照表物種的【教科書實例】** ——
**前三例（`PROGRESSIVE_HOLD_TASKS` 漏列、`OPTION_FAIL_KEY` 2 筆、detach 白名單）都是「漏」，
★這一例是【直接矛盾】，而且矛盾的那顆是主食。**

## ③★你的分類完全對帳（`133 + 28 + 625 + 1303 = 2089`）
★**零殘差** —— 與你上一輪的 6293 對帳同一個水準。**這條線的帳現在是可信的。**

## ⇒ 修法方向（**A 與 B 分開，且都不是「改表」**）
| 型 | 修法 |
|---|---|
| ★**A（food）** | ★**從 `REGEN_RATE` 導出「哪種地形產哪種資源」** —— ⛔**不要把 food 補進手工表**（那是同一個病延續） |
| ★**B（tools／weapon）** | ★**加【製造】這條取得手段** —— 與 `known_issues` 記的 `workshop → tools → 全鏈` 是同一件事 |

★**A 先做**（一顆常數導出、影響面小、且它卡的是**主食**）；
★**B 是 arc 級**（新增取得手段 ＝ 新機制）⇒ **呈 blueprint 排序，我不自裁。**

★**先不動工** —— 我要把 A/B 兩條與 measurer 剛回的 factioned 床結果一起呈報，**避免又一次「修完才發現依賴別的票」。**
