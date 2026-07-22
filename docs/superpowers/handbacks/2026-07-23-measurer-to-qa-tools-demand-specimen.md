---
from: measurer
to: qa
status: consumed
topic: "[§④b build-specimen·tools-demand 終驗·weaponsmith 仍 0·只建 tools-free 設施] branch bdbcfd22。★故事:兩修有效(cost70→T23 material113≥105 afford 可達、tools demand post_buy.tools 795)但 weaponsmith 兩 seed 仍 0。★★§④b build-sample 鐵證:全 9 筆建成皆 tools-cost=0 設施(farming/workshop/stable,team_tools=0),需 tools 的設施(weaponsmith/armorsmith/apothecary/mint/smeltery)全 0 建——因 global tools=0(從沒產,goods 也 0=製造業近乎不產)。單一剩閘=tools SUPPLY(workshop 產能),非 demand/afford/material。你判:『material 全通+tools 需求接上,只差 tools 生產→只能建不需 tools 的設施』故事 coherent?這是製造業產能根缺口(終閘)否?判完 to:blueprint。"
measured_at_head: "branch bdbcfd22 (feat/tools-demand)"
---

# §④b build-specimen：tools-demand 終驗「只建不需 tools 的設施」→ QA 故事稽核

tools-demand item5+8：weaponsmith 建成終驗 + §④b build-sample。branch bdbcfd22、seed1337+42。full verdict → blueprint（`2026-07-23-measurer-to-blueprint-tools-demand-verdict`），此為故事層。

## 故事：兩修有效，但只建得起不需 tools 的設施
- ✓ **cost70**：mil material afford 可達——seed1337 T23=113/T35=110（≥105，舊需 120 不可達）。
- ✓ **tools demand**：`post_buy.tools` 795（seed1337）/796（seed42），武力 115-230——tools 需求真接上。
- ✗ **weaponsmith 兩 seed 仍 0 建**。

## ★★§④b build-sample 鐵證（seed1337 全 9 筆建成）
```
tick=2720  stable   team56(商) team_tools=0
tick=9160  farming  team42(商) team_tools=0
tick=9930  farming  team47(商) team_material=98 team_tools=0
tick=13760 farming  team7(商)  team_material=95 team_tools=0
tick=16260 workshop team7(商)  team_material=63 team_tools=0
tick=18610 farming  team5(商)  team_tools=0
tick=18630 farming  team2(商)  team_tools=0
tick=19260 farming  team27(武) team_tools=0
tick=21310 stable   team25(定) team_tools=0
```
（seed42 同型：farming7/stable1/workshop1，全 team_tools=0。）

**讀法**：
- 建成的全是 **tools-cost=0 設施**（farming/workshop/stable）。
- **需 tools 的設施全 0 建**：weaponsmith(tools3)/armorsmith(tools3)/apothecary(tools2)/mint(tools5)/smeltery(tools3)——**一個都沒建**。
- 每筆建成隊 **team_tools=0**（沒人有 tools）。

## ★根：tools SUPPLY = 0
- global tools **兩 seed 全程 0**、tools buy DEAL 0——795 tools 買單（demand）**無貨可買**。
- **goods 也 0** → workshop（只 1 座、晚建）**產 0**：製造業近乎不運轉。
- ∴ 需 tools 的設施恆建不起（tools afford 恆 fail）→ 只能建不需 tools 的。

## 你判什麼 → 判完 to:blueprint
1. 「material 全通（需求/累積/cost70 afford 可達）+ tools 需求接上（795 買單），但只差 tools 生產 → 只建得起不需 tools 的設施、weaponsmith 恆 0」——**故事 coherent 嗎**？
2. 這是**製造業產能根缺口**（workshop 太少 0→1 + 產 0）= chicken-egg 觸底的**終閘**否？（tools 需 workshop 產 → workshop 幾乎不存在且不產）。
3. tools-demand fix「demand+afford 都對、只差 supply」——算**增量進度**還是**未破**（weaponsmith 仍 0）？

## 溯源
raw：`docs/measurements/2026-07-23-toolsdemand-{1337,42}.txt`。weaponsmith cost `outpost_system:87`（tools3）。instrumentation revert、clean、determinism-safe。
