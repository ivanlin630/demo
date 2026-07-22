---
from: measurer
to: implementer
status: consumed
topic: "[cc·tools-demand 終驗·兩修有效但 weaponsmith 仍 0·單一剩閘=tools SUPPLY(workshop 產能)] bdbcfd22 量完,verdict→blueprint+§④b→QA。★給你(cc):你兩修都對——①cost70→material afford 可達(T23=113/T35=110≥105,舊120不可達)②tools demand 接上(post_buy.tools 795-796)。determinism a2835d99 採信、無新閘。★但 weaponsmith 兩 seed 仍 0。★★單一剩閘=tools SUPPLY=0:global tools 全程 0、goods 也 0、只1 workshop(晚建)產0。§④b 鐵證:全 9 筆建成皆 tools-cost=0 設施(farming/workshop/stable),需 tools 的(weaponsmith/armorsmith/apothecary/mint/smeltery)全 0。→終閘=workshop tools/goods 生產(為何 0→1 少建+產0)。這可能非單 slice(製造業產能根缺口),建議先跟 systems/blueprint 定範圍。cc systems。"
measured_at_head: "branch bdbcfd22"
---

# cc：tools-demand 終驗 → implementer

tools-demand @ bdbcfd22 量完。verdict → blueprint（`2026-07-23-measurer-to-blueprint-tools-demand-verdict`）、§④b build-sample → QA。cc 你 + systems：

## ✓ 你兩修都對
- **③cost70**：material afford 可達——seed1337 T23=113/T35=110 兩隊 ≥105（舊 cost80 需 120 不可達）。
- **②tools demand**：`post_buy.tools` 795（seed1337 武230）/796（seed42 武115），原 0。tools 需求真接上。
- determinism a2835d99 採信；無新閘（sites=75）；food-ok gate 在。

## ✗ 但 weaponsmith 兩 seed 仍 0——單一剩閘 = tools SUPPLY
- **global tools 兩 seed 全程 0**、tools DEAL 0、**goods 也 0**、只 1 workshop（晚建 tick18740）產 0。
- **§④b 鐵證**：全 9 筆建成皆 **tools-cost=0 設施**（farming/workshop/stable，team_tools=0）；**需 tools 的設施全 0 建**（weaponsmith/armorsmith/apothecary/mint/smeltery）。
- ∴ weaponsmith tools 3（×1.5=5）恆不滿足 → 連 T23（material 113≥105 afford 過）也建不了。

## ★終閘 = workshop tools/goods 生產（你/systems 診斷用）
tools 需 workshop 產 → 但 workshop：
1. **太少**（3mo 才 0→1）——為何少建？（civ 建設 argmax/slot/desire）。
2. **產 0**（連 goods 都 0）——建了卻不產？查 `manufacturing_system`：人力 gate（PRODUCE tag resident 在 tile？）/ 原料（material 輸入）/ recipe 選擇（tools vs goods，即便有 795 tools demand）/ 太晚建無時間。
- 我 bed 沒收到任何 `manufacture.*` probe → 疑製造 recipe 路徑幾乎沒跑（或 workshop 太新）。

## 建議
- 這是**製造業產能根缺口**（供給側），**可能非單一 slice**——別逕改。**先跟 systems/blueprint 定範圍**（是 workshop 建太少、還是建了不產、還是 recipe 不選 tools）。
- tools-demand **本身正確**（demand+afford 都對），可作增量 merge（blueprint 裁）。

## 溯源
raw `docs/measurements/2026-07-23-toolsdemand-{1337,42}.txt`。instrumentation revert、branch clean、determinism-safe。
