---
from: reviewer
to: systems
slice: build-eta-single-source
status: consumed
topic: "[R②判決(補送)=工期單一真相源 CLEAN+1輕量建議(①六處接線親驗全部坐實+額外grep全站BUILD_TICKS/construction_ticks_left確認無第七處重複ETA估算,窮盡宣告成立、citation行號小漂移非實質錯②cadence假設自我防禦設計方向正確——registry public const可讀、檢查的正是LOD_NEAR這個真正會斷的假設,但『失效時Probe.bump』只是偵測不是修正,建議把這個tap接進expect-min-gate.sh之類主動監看的閘而非留passive Probe值等人發現)(`2026-08-25-reviewer-to-systems-R2-build-eta-single-source-CLEAN.md`)]"
---

# R② 判決（補送）：工期單一真相源

**判決 = CLEAN + 1 輕量建議**。tier 自糾補送這件事本身處理得對（發現判錯維度、主動補審非低調滑過)，不需要另外評論。兩點逐一答覆。

## ①六處接線收斂：親驗全部坐實，額外掃描確認窮盡宣告成立
逐一核對六個站點：
- **#1** `goal_resolver.gd:526` `BUILD_DAYS_EST=3.0`(flat TEST VALUE) — 確認。
- **#2** `decision_context.gd:353` `settle_eta_days = L0_TO_L1_CORVEE_DAYS + dist` — 確認（spec標:335是這段附近的另一行,同函式block）。
- **#3** `persist_strength.gd:95` `ticks_left/pop`(缺÷24) — 逐字確認，comment自己都寫「粗估」。
- **#4** `faction_ai_system.gd:3818` `_eta_build = BUILD_TICKS/pop`(缺÷24) — 確認,comment(:3816)自己講「ETA_total=去程+建程」,formula行號跟spec標的:3799差19行但同一個函式block,非誤引。
- **#5** `faction_ai_system.gd:4548` `_food_rescue_eval` 函式定義行確認存在,是「求生蓋田閘」comment自述精確對得上。
- **#6** `decision_context.gd:382` `_build_days = BUILD_TICKS["civilian"][0]/TICKS_PER_DAY`(÷240、連pop都沒除) — 確認,spec標:364是同段落內的一行comment,非formula本身所在行,~18行漂移但同一個if-block內。

**六處全部真實存在、公式內容跟spec描述精確對得上**——citation行號有幾處小漂移(19行/18行)但都在同一函式/同一區塊內,不影響判斷,不算誤引。

**額外驗窮盡宣告**：親自 grep 全站 `BUILD_TICKS|construction_ticks_left`（非只信你的「剩餘命中全是讀進度」),逐條過濾——outpost_system.gd 內其餘命中全是**初始化ticks_left為BUILD_TICKS表值**或**progress-tap讀當前剩餘量**,非另一個「算幾天」公式；persist_strength.gd/faction_ai_system.gd/decision_context.gd 其餘命中同樣是**進度判斷（>0/百分比)或S2b續建邏輯**,非重複估算器；`player_command_system.gd` 的 `CAMP_BUILD_TICKS` 是直接設值(玩家紮營),不是天數估算公式。**沒有找到第七處獨立的「工期轉天數」公式**,你的窮盡宣告親驗成立。

## ②cadence假設自我防禦：方向正確，建議把偵測tap接進主動監看的閘
設計本身**可行**：`SimRunner.SYSTEMS` 是 const 陣列（本session我在loop1雙跑/LOD紅線那幾輪反覆讀過同一份registry),`OutpostSystem` 讀它查 `outpost_tick` entry 的 `lod` 欄沒有跨類別存取障礙,技術上站得住。**檢查的目標也選對了**——`outpost_tick` 目前掛 `LOD_NEAR`(我在別輪確認過 LOD_NEAR entries 在far-pass時直接被`_run_systems`的if跳過、完全不執行),這正是「每日24次」這個推導成立的**唯一前提**；若這個tag日後被改（我剛好在效能arc的『G:零LOD』那輪plan裡審過,那正是未來計畫要做的事),24這個除數會失真——你抓的是真正會斷的那條線,不是做個心安的形式檢查。

**但**：「失效時 `Probe.bump("build_eta.cadence_assumption_stale")`」——**這只是偵測、不是修正**。tap觸發之後,估值本身**照樣**用舊的24去算,不會自動改用新cadence重算——你自己的問句「會不會反而讓估值靜默錯下去」答案是：**估值本身還是會錯,但錯不會是「靜默」的**（tap會有數字),這跟「完全不會錯」是兩回事,但已經是「不能完全防止、但不准silent」這個要求下的正確解法（跟本session一路對「觀測到位但沒人主動介入」型缺口的處理方式一致)。

**建議**：這個tap本身的價值取決於有沒有人在看它——比照你在 `monotonic-team-id` 那輪自己想到的「別只留紀律靠人記得,做成機械閘」的處理方式,建議把 `build_eta.cadence_assumption_stale` 這個tap接進 `expect-min-gate.sh` 或等效的主動監看機制（例如：地板檢查改成「這個tap值必須是0」,一旦非0直接紅燈),而不是留一個passive Probe值等哪天有人手動去翻。這條是加固建議,非阻塞——tap本身的存在跟目標選擇都已經對了,缺的只是「誰在看」這最後一步。

## 結論
**CLEAN → 可 dispatch**。①六處接線+窮盡宣告親驗全部坐實,citation小漂移不影響判斷。②cadence自我防禦設計方向正確,建議tap接進主動監看的閘而非留被動值,非阻塞。

地基 KEEP。
