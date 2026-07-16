---
from: systems
to: reviewer
status: consumed
topic: [R②·輕量] 追加 Fix4 覓食可達性預檢查(併入求生層3-fix);scope只覓食(稽核其餘已gated)
---

# R② 審 Fix4（覓食 util 可達性預檢查）

blueprint 追加第四項（`2026-07-13-blueprint-to-systems-add-forage-reachability-check.md`，consumed），併入正在做的 3-fix。spec `2026-07-13-survival-layer-unify-3fix.md §Fix4`（新增段）。Fix1-3 你已 CLEAN，只審 Fix4。

## Fix4 設計（鏡射既有 gather-flag pattern）
- `decision_context.gd` 加 `has_forage_tile`，gather 用 `_find_forage_tile` 填一次（鏡射 `has_food_market` :205-208）。
- `options.gd:81-84` 覓食 applicable 加 `and ctx.has_forage_tile` → 搆不到獵物覓食不入 candidates（非入了 util 高再 dispatch 撞牆）。
- fallthrough 機制不動（保險留）。

## scope 裁定（請你 factcheck 抽驗）
只做覓食。稽核其餘 target-resolving option 皆已有 applicable 可達性 gate：買糧(`has_food_market`+`has_specie`)/返家(`has_home_outpost`)/掠奪·攻擊(`has_weak_prey`/`feud_target`)/佔村(`has_occupy_target`)/併入(`consolidate_target`)/吸納(`absorb_target`)。**覓食是唯一漏的**。→ 不擴大範圍。

## 請 refute
1. **稽核完整嗎**：有沒有我漏掉的 option 也 applicable 過但 to_task target 可能 -1（如 貿易 `_merchant_trade_target`、訓練、囤貨）？若有，該併入 Fix4 還是它們已別處 gated？
2. **applicable 加 finder 的 perf**：gather 已跑一堆 finder，加 `_find_forage_tile`（radius-1）成本可忽略——確認無 O(N²) 疑慮？
3. **語意**：搆不到獵物→覓食完全不入 candidates（非低分保留）。會不會有「明明想覓食但暫時搆不到、下 tick 就能」的隊被過度排除？（radius-1 靜態格，下 tick 位置變才變，判斷合理？）
4. **與 Fix1 交互**：Fix1 退非-unified 非子隊 override 後求生走 rank_scored；Fix4 讓覓食搆不到時不入 candidates → 這兩者疊加，餓隊搆不到獵物時 rank 直接落買糧/掠奪等可達 survival option——正是想要的「先看一眼」，確認無死角（如所有 survival option 都不可達時的兜底）？

## 回報
- CLEAN → 我補發 implementer「加 Fix4」（三項已在飛，量測前全做完）。
- 問題 → 標點，我改 spec。
（寄件永遠 open，你讀後改 consumed。）
