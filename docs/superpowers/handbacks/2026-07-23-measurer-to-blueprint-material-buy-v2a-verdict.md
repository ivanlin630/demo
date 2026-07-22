---
from: measurer
to: blueprint
status: consumed
topic: "[verdict·material-buy v2a(1076c0d5)·進步但目標仍未達·★真根更深=build 閘非 material-trade] baseline=merge-base d59b171b(matched seed1337 3mo)。v2a 三修有效:①full-need 把 mil material 累積推高(T28 peak 117 vs baseline 98)②買料 option 競得過(chosen 80-307)③food-ok gate=starve 0 無餓死回歸。★但 weaponsmith 兩 seed 仍 0→0、material buy DEAL 仍≈0-3(no_want 仍 77)。★★patch-gate-first 挖到真根(比 material-trade 更深):weaponsmith build 卡兩硬閘,皆非 material-trade 能解——①afford ×1.5(faction_ai:2572)=需 material 120,teams 封頂~117(連 v2a full-need 最高才 T28=117)②tools=0 全域(weaponsmith 需 tools 3×1.5=5,tools 從沒產)。血證:baseline T26 material80+coin70(都夠 base cost)仍沒建→坐實是 build 閘非供給。∴material-buy arc(v1/v2a/v2b coin)必要但不充分,build 閘(afford120+tools0)才是 weaponsmith 未建真牆。doom mixed=世界分岔(deal≈0 無法致)。建議:v2a 可作進度 merge,但 weaponsmith 目標另需 afford×1.5 重估(120 不可達,~117 封頂)+tools 生產鏈(全域 0)。cc systems/implementer。"
measured_at_head: "branch 1076c0d5 (feat/material-buy v2a) vs baseline d59b171b (merge-base)"
seeds: "1337（baseline+v2a 各 3mo，matched）+ 42（v2a 3mo；4mo GODOT_TIMEOUT——v2a 較慢=買料路由增存活）"
---

# material-buy v2a verdict → blueprint（進步·目標仍未達·真根更深）

implementer v2a 工單（`2026-07-23-implementer-to-measurer-material-buy-v2a`，consumed）。branch `feat/material-buy` @ 1076c0d5（v1 ca199844 疊 ①full-need ②util 繫建設 ③food-ok gate）。baseline = merge-base d59b171b。`--path`。temp 探針 + bed **已 revert、branch clean、grep 零殘留**。

## v2a 三修：皆有效（vs baseline，seed1337 3mo matched）
| 指標 | baseline-1337 | v2a-1337 | 讀法 |
|---|---|---|---|
| mil material peak **最高** | 98（T23） | **117（T28）** | ★①full-need 推高累積（+19，逼近閾） |
| mil peak≥80 隊 | 4/23 | 3/18 | 相當（隊數不同） |
| `買料` option chosen | （無此 option） | 80（seed42=**307**） | ★②util 繫建設→競得過 |
| extinct.starve | 1 | **0** | ★③food-ok gate＝無餓死回歸 |
| attrition | 5.9% | 7.4% | mixed（noise/分岔） |

→ 三修**方向對、機制真動**：material 累積推高、買料選得動、餓時不亂買（starve 0）。

## ★但 stated goal 仍未達
| 指標 | baseline | v2a-1337 | v2a-42 |
|---|---|---|---|
| **weaponsmith built** | 0→0 | **0→0** | **0→0** |
| **material buy DEAL** | ≈0 | **3** | **0** |
| no_want（MTL material） | — | 77 | 33 |
| weapon 產出 | 31 | 33 | 34 |
→ weaponsmith **兩 seed 仍 0 建**、buy DEAL 仍≈0-3（no_want 仍高）、weapon 未產。

## ★★真根（patch-gate-first 挖到，比 material-trade 更深）
weaponsmith build 卡**兩硬閘，皆非 material-trade 能解**：
1. **afford ×1.5**（`faction_ai_system.gd:2572` `if avail < cost[k]*1.5: return`）：weaponsmith cost material 80 → **需 120**。v2a 全場最高累積 **T28=117**（baseline 98）——**連 full-need 推到 117 仍差 3 到 120**，teams 封頂 ~117。→ ×1.5 buffer 的最後 40 不可達。
2. **tools=0 全域**（上輪 verdict 已測；本輪重確認 tools 產出=0）：weaponsmith 需 tools 3（×1.5=**5**），**tools 從沒被生產** → afford 的 tools 條件恆 fail，material 再多也建不了。
- **★血證**：baseline **T26 material=80 + coin=70**（兩者都夠 base cost 80+3）**仍沒建** weaponsmith → 坐實 build 卡在**閘（afford×1.5 + tools=0）非供給**。

∴ **material-buy arc（v1 需求接線 / v2a full-need+util / 計畫 v2b coin）必要但不充分**——即便材料買賣完美，team 累積到 ~117 仍被 afford-120 擋 + tools=0 擋。build 閘才是 weaponsmith 未建的真牆。

## doom-delta（正負皆記）
seed1337 v2a 7.4% vs baseline 5.9%（略差）；seed42 v2a 5.8%/starve0。**mixed、非 robust**——material deal≈0 無法致真 doom 變 → 世界分岔（買料路由改 trajectory）非 material 效。誠實記：無可歸因 doom 效，但**無餓死回歸（food-ok gate 有效，starve 0）**。

## owner-depletion
市場 material 未被吸乾（deal≈0-3 吸不動）。無塌陷。

## 淨判 + 下一站
- **v2a = 真進度**（累積推高 T28→117、買料競得、food-safe、無餓死回歸、無迴歸）——可作**增量 merge**（blueprint 裁）。
- **但 weaponsmith 目標未達**，且**真根更深**：不在 material-trade（v2b coin 也不會解），在 **build 閘**：
  1. **afford ×1.5 重估**：weaponsmith 120 不可達（teams 封頂 ~117）——×1.5 是否對 weaponsmith 過嚴？（×1.3=104 可達）。
  2. **tools 生產鏈**：tools 全域 0（從沒產）→ weaponsmith tools 需求恆不滿足。tools 生產（workshop tools 產出）是獨立缺口。
- QA 讀 §④b specimen 判故事（`to:qa` 另發）；cc systems/implementer（真根 = build 閘非 trade，v2b 前先評 afford+tools）。

## 溯源
raw：`docs/measurements/2026-07-23-gateb-{v2a-1337,v2a-42,baseline3mo-1337}.txt`（+ baseline 4mo `gateb-baseline-*`）。afford 閘 `faction_ai_system.gd:2572`；weaponsmith cost `outpost_system.gd:86-87`（material80/tools3）。branch instrumentation 已 revert、clean。determinism：implementer 報 seed1337×2mo byte-identical（MD5 99b47415）；我探針 bump/read only 零 RNG。seed 4mo timeout=右尺寸（非迴歸，rule3）→ 3mo 完成。
