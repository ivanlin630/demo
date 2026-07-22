---
from: implementer
to: measurer
status: consumed
topic: material-buy v2a — measure（Gate B 半破→閉環①③，full build-need+util 繫建設+food-ok gate）
branch: feat/material-buy
commit: 1076c0d5
spec: docs/superpowers/specs/2026-07-23-material-buy-v2a-full-need-utility.md
---

# material-buy v2a — 做完，量測請收（疊 v1 ca199844 續）

## 改動（3 fix 疊 v1，皆繫「想建 facility」means-end 信號）
v1 半破根 = need 進了 need_keep 但**執行稀釋**（QA:want 接上 buy-to-80 未達）。修：

- **① full build-need**（`need_oracle._construction_facility_need`）：`total += cost_mat*desire`
  → **`total += cost_mat`**。desire 已在上方 `if desire < CONSTRUCTION_DESIRE_MIN: continue` 當 **gate**，
  過閘=夠想建→**全 cost 80**（非稀釋 24=建不了白買）。cap 100 仍在。
- **② buymaterial_drive 繫建設迫切**（`terms.gd` + 新 `NeedOracle.max_material_facility_desire`
  + `decision_context.material_build_urgency`）：`drive = shortfall/CAP × max material-facility _facility_deficit`
  （買料=建設前置，想建強+缺料多→競得過建設，非 0.5-1.0 band 墊底 1.7%）。weight 穿人格保留。
- **③ ★food-ok gate**（`options.gd` 買料 applicable，reviewer R² 結構要求）：+`food_days >= DESPERATION_DAYS`
  （鏡射買糧 `food<DESPERATION`=互斥）→餓時只買糧、食足才投資建設料=**結構防餓死**（買料非 survival-class，
  util 高會搶 survival rank）。

## 自驗（皆綠）
- TDD 8/8（`material_buy_test`）。RED 確認：①full 80→稀釋 30.2 / ③drive hi=lo=1.0 flat band / ④餓隊 gate 移除→applicable。
- headless 0-new（3 baseline：p2a join weight / combat_target 197 / rung intent）。
- gate PASS sites=75（無新閘）。
- determinism seed1337×2mo×2 跑 byte-identical MD5 `99b47415`（純 utility 無 RNG，diff 無 randf）。

## 量測請抓（spec §驗收，餵 QA 判故事）
1. **material buy DEAL**：v1≈0（1337=2/42=0）→ v2a ?（chicken-egg 真破否）。
2. **no_want 率**：v1 72% → ?（full need 應降）。
3. **買料勝率**：v1 1.7%（6044× 只勝 102）→ ?（合理區間，別過衝變只買不建）。
4. **★有-coin mil 隊 buy-to-80 達成率**：驗機制（有 coin 隊該達 80+建成）。
5. **weaponsmith 建成**：v1 兩 seed 0→0 → ?（means-end 真導向建成）。
6. **★無餓死回歸**（food-ok gate 驗）：餓隊不買料、starve/pop 不惡化。
7. **doom-delta**：對敗北/殲滅曲線（正負皆記）。
8. **§④b bounded sample**（`Probe.bump_sample`）：前 N 筆買料 decision specimen → QA 讀決策故事
   （誰、缺多少、為建啥、buy-to-80 達否、cap 有無觸、food-ok 有無擋餓隊）。

床：`godot --path .worktrees/material-buy` 對 branch 1076c0d5 跑（★禁原地 checkout）。
**★★measure 帶 §④b + specimen → QA 判故事**（長跑新規則）：想建→買料達 80→建成 coherent；
**無 coin 隊卡 = 確認 coin 唯一剩 blocker → v2b**（②coin 另 slice：mil loot→anon_treasury 不流 team.coin）。

## 溯源
接 v1 branch feat/material-buy 續（1076c0d5=v1 ca199844 上疊 ①③）。完成判定=systems+reviewer。做完→to:QA。
