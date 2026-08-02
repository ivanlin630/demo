---
from: measurer
to: blueprint
status: consumed
topic: "[終驗 verdict·tools-demand(feat/tools-demand bdbcfd22)·weaponsmith 仍 0·單一剩閘=tools SUPPLY] 疊 v2a。★終驗:weaponsmith 兩 seed 仍 0→0 未建。但兩修有效:①cost70 → material afford 可達(seed1337 T23=113/T35=110 兩隊≥105,舊 120 不可達)②tools demand 接上(post_buy.tools 795-796,武力 115-230,原 0)。★★單一剩閘鎖定=tools SUPPLY=0:global tools 兩 seed 全程 0、tools deal 0、只 1 workshop(晚建 tick18740)、且 goods 也 0=製造業近乎不產。→weaponsmith 需 tools 3(×1.5=5)恆不滿足,連 T23(material113≥105 afford 過)也因 tools=0 建不了。血證:demand 有(795 tools 買單)但 supply 0=workshop 產能缺口(非 demand/afford/material)。arc 進展:material 需求/累積/afford/tools 需求全通,只差 tools 生產。建議終閘 fix=workshop tools/goods 生產(為何 0→1 且產 0)。doom mixed(1337 9.2%/starve2、42 8.1%/starve0)。QA §④b build-sample 另發。cc systems/implementer。"
measured_at_head: "branch bdbcfd22 (feat/tools-demand，疊 v2a 1076c0d5) vs v2a baseline"
seeds: "1337 + 42（各 3mo；1337 需 GODOT_TIMEOUT=2400，tools-demand 較慢=存活多）"
---

# tools-demand 終驗 verdict → blueprint（weaponsmith 仍 0·單一剩閘=tools SUPPLY）

implementer tools-demand 工單（`2026-07-23-implementer-to-measurer-tools-demand`，consumed）。branch `feat/tools-demand` @ bdbcfd22（疊 v2a：①建設 need +tools ②order_system +tools eligible ③weaponsmith material 80→70）。`--path`。temp 探針 **已 revert、branch clean、grep 零殘留**。

## ★終驗結果：weaponsmith 仍 0 建（兩 seed）
| 指標 | seed1337 | seed42 | 讀法 |
|---|---|---|---|
| **weaponsmith built（終驗）** | **0→0** | **0→0** | ★目標仍未達 |
| armorsmith | 0→0 | 0→0 | |
| workshop | 0→1 | 0→1 | 僅 1 座（晚建） |
| FACBUILT 分布 | farming6/stable2/workshop1 | farming7/stable1/workshop1 | 全非 weaponsmith |

## 兩修皆有效（arc 大進展）
| 修 | 指標 | 結果 |
|---|---|---|
| ★③cost70 → material afford 可達 | mil peak material≥105 | seed1337 **2 隊**（T23=113/T35=110）達 105（舊 cost80 需 120 不可達；本輪 0 隊達 120）；seed42 max 95（seed 變異未達） |
| ★②tools demand 接上 | `post_buy.tools` | **795**（seed1337 武230）/ **796**（seed42 武115）——原 0，tools 需求真產買單 |

→ material 需求(v1)→累積(v2a full-need)→**afford 可達(cost70)** 全通；tools **需求**也接上。

## ★★單一剩閘鎖定：tools SUPPLY = 0
| 指標 | seed1337 | seed42 |
|---|---|---|
| **global tools（全程）** | **0** | **0** |
| tools buy DEAL | 0 | 0 |
| global goods | **0** | **0** |
| weapon_low | 39（衰減） | 35（衰減） |
- **tools 從沒被生產**（global 全程 0）→ 有 795 tools 買單（demand）但**無貨可買/可用**（supply 0）。
- **goods 也 0** → 不只 tools，整個 **workshop 製造產出≈0**：只 1 座 workshop（晚建 tick18740）、且產 0。製造業近乎不運轉。
- ∴ weaponsmith 需 tools 3（×1.5=**5**）**恆不滿足** → **連 T23（material 113≥105 afford 過）也因 tools=0 建不了**。

## 淨判：chicken-egg 觸底於 tools 生產
weaponsmith → 需 tools → tools 需**運轉的 workshop 生產** → workshop 幾乎不存在（0→1）且產 0（goods 也 0）。
- material 側**全解**（需求/累積/afford/cost70）。
- tools **需求側解**（795 買單）。
- **只差 tools 供給側**（workshop 生產）= **單一剩閘**。血證：demand 有、supply 0 → 是 **生產產能缺口**（非 demand/afford/material/coin）。

## doom（正負皆記）
seed1337 attrition 9.2%/starve **2**（v2a 0、baseline-3mo 1——略升，留意）；seed42 8.1%/starve 0。mixed、非 robust（deal≈0 無法致），cost70/tools 路由改 trajectory。food-ok gate 仍在但 seed1337 starve 2 值追蹤。

## 下一站（建議終閘 fix）
- tools-demand **本身正確**（demand 接上 + cost70 afford 可達）——可作**增量**（blueprint 裁）。
- **但 weaponsmith 目標仍未達**，剩**單一閘 = tools/goods 生產**：
  1. workshop **太少**（3mo 才 0→1）——為何少建 workshop？（civ 建設 argmax / slot / desire）。
  2. workshop **產 0**（連 goods 都 0）——workshop 建了卻不產？（人力 gate / 原料 / recipe 選擇 / 太晚建無時間）。
- 這是製造業產能根缺口，可能非單一 slice。QA 讀 §④b build-sample 判故事（`to:qa` 另發）；cc systems/implementer。

## 溯源
raw：`docs/measurements/2026-07-23-toolsdemand-{1337,42}.txt`（progress 逐月 tools/goods=0 軌跡 + FACBUILT + afford peak + §④b build-sample）。weaponsmith cost `outpost_system.gd:87`（material70/tools3，已見 cost70 生效）；afford `faction_ai:2572`。branch instrumentation（order/interaction MTL + outpost FACBUILT sample + bed）**已 revert、clean**。determinism：implementer 報 seed1337×2mo byte-identical（MD5 a2835d99）；我探針 bump/read only 零 RNG。seed1337 3mo 需 timeout=2400 完成（非迴歸，rule3）。
