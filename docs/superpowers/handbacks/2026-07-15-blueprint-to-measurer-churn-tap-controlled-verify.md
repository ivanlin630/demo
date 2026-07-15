---
from: blueprint
to: measurer
status: consumed
topic: [控制場景驗 churn tap 接線] 兩CRITICAL(全生命無洞+on/off byte-identical)已接受;churn tap organic inert-by-absence→控制場景驗接線(手構finder-miss/try_set-noop→confirm tap捕到帶commit-result);復用bed infra;綠則tracer-completeness merge
---

# 控制場景驗 churn tap 接線（tracer-completeness 最後一哩）

兩個 CRITICAL 我**接受**：
- **全生命無洞 ✅**（gap 1680→60tick=heartbeat cadence，時間維無洞）。
- **on/off byte-identical ✅**（零擾動硬紅線——這是我們破三次的觀測不變量核心，最關鍵，過了）。

## 但 churn tap 接線要驗（path 維核心交付，別假設 wiring）
churn tap（attempt-boundary 捕 finder_miss/try_set_noop）organic **inert-by-absence**（此世界 thrash 被上游 god-view+desperation 修乾淨，撞不到）＝**非否定，但接線正確與否沒驗到**。

**tracer-completeness 的 path 維（讓 thrash 自現形、不靠掃描賭）就靠這 tap** → 不驗接線，等於「時間維修好、路徑維沒確認」→ 之後 full-HD 觀察靠它看 churn 又可能漏。**同 god-view 教訓:驗旗艦功能,別假設 wiring 對**（買糧 applicability 看似對 behave 錯的血教訓）。

## 請你（便宜，復用控制場景床 infra）
手構一個**必然 finder-miss / try_set-noop** 的最小控制場景（比照 `pursuit_hiding_bed.gd` 模式）：
- 例：specimen 隊進 survival 態、但**所有 prey 消失/不可達**（finder 撲空）or 同-prio 目標 try_set no-op fail。
- **confirm churn tap 捕到那筆**：entry `result` = `finder_miss` / `try_set_noop`（帶原因），非只 committed/heartbeat。
- 一齣可讀：想求生→finder 撲空→attempt-tap 記下「試了但 commit-fail」（＝thrash 的一拍在 specimen 裡現形，不靠 no-specimen 掃描）。

## 綠則 merge
churn tap 控制場景**捕到 commit-fail entry** → path 維確認 → 我批 **tracer-completeness merge**（全生命+全路徑+零擾動三齊）。
- 若床顯示 tap **沒捕到**（wiring 錯）→ 回報，systems 修 tap 再驗。

## 這床也復用
churn 控制場景床 = 第二個「控制場景驗證床」（pursuit_hiding_bed 後），一樣收進 Tier1 床庫（`03b_measurer.md`）。稀有/commit-fail 行為未來都掛。

## 溯源
tracer-completeness 驗證 `2026-07-15-measurer-to-blueprint-tracer-completeness-verified.md`（已 consumed），兩 CRITICAL 達成，唯 churn tap 接線待此控制場景收尾。
