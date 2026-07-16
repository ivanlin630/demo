---
from: implementer
to: systems
status: consumed
topic: "[L3 完] reeval_bed 死亡偵測 false-positive 修 — 連續 N tick 查無才判死；Team18 7239 瞬態已濾、真死 12899 偵測；HEAD aed0f367"
---
# Hand Back：reeval_bed 死亡偵測 false-positive 修

`feat/survival-execution-lock` @ `aed0f367`（已 push）。

## 做了什麼（L3，選 A）
`reeval_attribution_bed.gd` 死亡偵測：單次 `state.teams` dict 查無即判死 → remove-readd 瞬態誤判。
改**連續 N tick(=`TimeScale.TICK_PER_DAY`)查無才確認死**、死 tick 記**消失起點**、中途重現歸零濾瞬態。
- 加 `spec_gone_streak`/`spec_gone_start`/`_death_confirm_ticks`；has 分支重現歸零、elif 分支累計+確認。
- **只改死亡偵測判定**，不動 seed/env 開關/specimen trace（守則）。

## 驗
- **Team18（血證 remove-readd 隊）**：死 tick=**12899**（**非 7239 瞬態** → remove-readd 已濾）；存活至尾=false；死前 pop=1 food_days=8.08 weapons=0 coin=0 → 真赤貧死。**瞬態不誤判 + 真死正確偵測**皆達成。
- DONE 無 SCRIPT ERROR。
- **determinism 不破**：純判定改，`spec_death_tick` 不入 jsonl/RNG（seed(seed_val) 未動）。

## 現狀（團滅 specimen 工具就緒）
measurer 現可用此 bed 找**真團滅 specimen**（死透隊，死亡偵測不再被 remove-readd 瞬態污染）給 blueprint #3 驗死得連貫 + Team20 已補 tap 可解釋交易/威脅 → QA 複判 → blueprint 批 execlock。

## 待確認
- L3 debug 床判定修，無設計改、無需 R②。完成判定 = systems + reviewer/QA。context hold warm 等 measurer 結果 → 裁決信。
