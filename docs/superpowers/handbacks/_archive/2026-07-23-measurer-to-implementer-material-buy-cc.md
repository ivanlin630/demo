---
from: measurer
to: implementer
status: consumed
topic: "[cc·material-buy 量測完·機制接上目標未達·第二半待] feat/material-buy ca199844 量完,verdict→blueprint+specimen→QA。★給你(cc):你的需求半修對了——post_buy.material 0→127、買料 chosen 87-102、determinism byte-identical 驗到。但目標未達:material buy DEAL 仍≈0(1337=2/42=0)、weaponsmith 兩 seed 0→0 未建、weapon 未產。兩殘留 blocker:①執行 want-gate no_want 72%(reserve=need_keep×_reserve_factor,liquidation 係數稀釋掉你加的建設 need→到市場 want≤0)②coin 餓(§④b sample:成交買方 coin_after≈0.25-0.72,qty 只1-2)。第二半 fix 方向(待 blueprint/systems spec):執行側 want 認建設 need(繞過 reserve_factor 稀釋)+買方 coin。無迴歸、doom 不惡化(seed1337 甚至改善但非 robust=世界分岔)。"
measured_at_head: "branch ca199844"
---

# cc：material-buy 量測完 → implementer

feat/material-buy @ ca199844 量完。verdict → blueprint（`2026-07-23-measurer-to-blueprint-material-buy-verdict`）、§④b specimen → QA（`2026-07-23-measurer-to-qa-material-buy-specimen`）。cc 你：

## ✓ 你的「需求半」修對了
- `post_buy.material` 0→**127**、`買料` option chosen 87-102（applicable 6000-17000）——means-end need 真產買單、option 真 fire。
- determinism：你報 seed1337×2mo byte-identical（MD5 57f44e2a）我採信；我探針 bump/read only 零 RNG。
- 無迴歸、doom 不惡化（seed1337 attr 10.4→5.6/starve 1→0；但 seed42 平 → 改善非 robust，deal≈0 無法致真 doom = 世界分岔非 material 效）。

## ✗ 但「目標半」未達
- material buy **DEAL 仍≈0**（seed1337=2/qty3、seed42=0）、**weaponsmith 兩 seed 0→0 未建**、**weapon 未產**（33-38 衰減）。
- chicken-egg 結果未破：teams 想買了，但**買不到** → 仍建不了。

## 兩殘留 blocker（第二半，待 blueprint/systems spec，別逕改）
1. **執行 want-gate no_want 72%**：`_market_visitor_buy` 的 `want = TradeValuation.reserve(material) − effective_holding`。`reserve = need_keep(含你加的建設 need) × _reserve_factor`（非活命品 liquidation 係數<1）→ **建設 need 被稀釋** → 持有>稀釋 reserve → no_want。你的 need 進了 need_keep（∴post 得出買單），但執行 reserve 被 factor 打折 < 建設實需。**post 與 execute 的落差**。
2. **coin 餓**：§④b sample 2 筆成交買方 `coin_after`≈0.25-0.72（花到近 0）、qty 只 1-2 → 累積不到 weaponsmith 80-120。

## 建議（非指令，等 blueprint 裁 merge-partial vs iterate）
第二半治點：執行側 want 認建設 need（繞 reserve_factor 稀釋，或建設品 reserve 不液化如 survival goods）+ 確保買方 coin。R② 過 reviewer 再 dispatch。

## 溯源
raw `docs/measurements/2026-07-23-gateb-*`。instrumentation revert、branch clean、determinism-safe。
