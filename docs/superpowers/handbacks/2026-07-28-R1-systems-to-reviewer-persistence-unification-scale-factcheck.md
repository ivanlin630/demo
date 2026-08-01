---
from: systems
to: reviewer
status: consumed
topic: "[R①·持守統一 factcheck·★異質框外驗規模斷言(寫 HOW spec 前)·三規模前提 code 坐實別假設:①23散機制真收成一套②兩層真共讀同一持守值③所有多tick動作真走同一套·★別重蹈 means-end R① 我 orientation『非新引擎』樂觀低估被異質駁血證·premise_contradiction→halt 回 blueprint 調 WHAT] 持守統一 WHAT 用戶核可,寫 HOW spec 前 R① 驗規模。WHAT spec+盤點底稿 23 機制在。統一模型觀察=待驗假設非斷言。"
---

# R①：持守統一規模斷言 factcheck（寫 HOW spec 前，異質框外）

持守統一 WHAT 用戶核可（`docs/superpowers/specs/2026-07-26-persistence-unification-design.md`）。**寫 HOW 架構 spec 前 R①**：驗三個**規模斷言**（means-end R① 血證：我 orientation「非新引擎」樂觀低估被異質 reviewer 駁 → 這次規模斷言**要 code 坐實別假設**）。

## 料
- WHAT spec（一個持守強度=人格加權沉沒+前瞻、兩層共讀、危機地板強制反應非逃、util 偏重非硬鎖、任務+資源持守、取代 23 散機制）。
- 盤點底稿 `docs/superpowers/2026-07-26-commitment-persistence-inventory.md`（23 機制，file:line，決策層 12 + 執行層 10）。
- ★systems 統一模型觀察（底稿 §共同模型）= **待驗假設非斷言**（3 症狀：bonus 全 flat 0.15 / 執行層 bespoke 散 / 扁平vs情境不一；候選模型：持守強度=f(進度,剩餘,中斷成本) 累積、兩層共讀）。

## ★三規模斷言（factcheck，異質框外，code 坐實）
1. **「23 散機制真能收成一套持守強度」**：親讀盤點 23 機制——真都是「同一個持守概念的不同 flavor」能收進一個持守強度嗎？還是**某些本質不同、收不進**？e.g. `combat_lock_absolute`（戰鬥絕對鎖）vs `TRADE_TIMEOUT`（貿易卡死保險）vs `COMMITMENT_BONUS`（rank 偏置）——這三個是同一持守值的不同讀法，還是三種不同機制被硬歸類？哪些真能 subsume、哪些是誤歸類（means-end 稽核 count 被 R① 打臉前科：散 7 處實 2 軸混）？
2. **「兩層真能共讀同一持守值」**：決策層（rank 偏置，util 加權，連續值）+ 執行層（gate，別落跑/別賣資源，二元判斷）——**同一個持守強度數字**真能兩層都讀嗎？單位/語意相容嗎？還是決策層要連續 util、執行層要 threshold，本質不同表徵、共讀是幻覺？
3. **「所有多 tick 動作真走同一套」**：施工/遠行/trade run/遠征/founding 真能一視同仁同一持守模型？還是某些動作本質需 bespoke（e.g. founding 距離縮放 timeout vs 施工 progress 累積，是同模型參數化還是不同機制）？

## 判準
- **premise_contradiction**（某規模斷言 code 坐實**不成立**，如「23 機制其實是 3 種不相容概念」）→ **halt** → 回 `to:systems`，我回報 blueprint 調 WHAT scope。
- CLEAN（規模斷言 code 坐實可成立，統一模型 scope 對）→ 我進 HOW 架構 spec。
- ★用異質模型 + 明確 refute（別 rubber-stamp「能收一套」——means-end 我樂觀低估血證）。

CLEAN → 我 HOW spec。contradiction → halt 回 systems。
