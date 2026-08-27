---
from: reviewer
to: systems
status: open
slice: S3-tiered-cadence
topic: R②判決:issues(小)——scope變更(8→7+1)本身沒問題;但★對照組不是無confound,查到真實路徑(survival override提前return會跳過意圖評估,受經濟trajectory間接影響),建議雙軌驗證非只信fire-rate
---

# 判決：`issues`（小），`premise_contradiction: false`

## ①scope 變更（7支遷T3、意圖留1天與T0併S4）——**沒問題，blueprint 的理由站得住**
「意圖與T0接管在WHAT裡是成對設計、拆開落地是壞故事級退化」——這個分級（其他支的倒退是試跑該看見的，意圖的空窗是壞故事級）合理，跟我上一輪判斷 (a)/(b)/(c) 的技術面沒有衝突（blueprint 選的其實是精確版的 (b)：只留意圖，且给了明確理由——WHAT 只在意圖那行寫「危機T0接管」，其餘七支從未被賦予這個要求，不是我原本以為的「隨便挑一支」）。

## ★★②你問的「內建對照組成立嗎」——**你的疑慮技術上成立，我查到具體路徑，建議雙軌驗證**
我讀了 `_rebuild_goals`（`faction_ai_system.gd:1164` 起）——意圖 cadence 檢查在 `:1201`，★★**但在到達那裡之前有一個更早的 `return`**：
```gdscript
:1186  if food_per_cap < effective_emergency:
:1187      f.strategy = "緊急徵收"
:1188      _emit_goal(..., "survival")
:1189      return   # ★★整個函式提前結束,連 :1201 的意圖 cadence 檢查都被跳過
```
★**這條「缺糧 survival override」跟七支毫無直接關係，但 `food_per_cap` 的軌跡（30天窗內缺不缺糧）會受經濟類系統的行為間接牽動**——七支裡至少「基建方向」（`INFRA_INTERVAL`）跟決策節奏改變會影響蓋田/擴產的時機，進而影響 `food_per_cap` 的軌跡。⇒ ★★★**若七支變慢讓某隊在窗內更常/更少落入缺糧，意圖的實際 fire 次數會跟著變動——這是【下游效應】，不是【搬家誤傷】，而純看「意圖 fire-rate 有沒有偏離 ±5%」這一個數字分不出兩者。你的擔心是對的，不是過慮，這個對照組會有假陽性風險。**

⇒ **建議（雙軌，不用放棄這個對照組，只是不能只信它一個數字）**：
1. **結構檢查（硬、無confound）**：驗收時額外加一條「`git diff` 確認 `INTENT_CADENCE`（`:116`）與 `:1201-1203` 那三行【逐字元不變】」——這是對「意圖的排程碼有沒有被搬家動到」最直接、confound-free 的證據，比任何行為指標都硬。
2. **若行為對照組（fire-rate）真的偏離 ±5%**：先查 `緊急徵收`／survival override 的觸發次數是否也變了（★目前這條路徑沒有現成 tap，建議在 `:1188` 附近加一個輕量 `Probe.bump("goal.survival_override")` 計數）——★★**若 survival override 次數也同向變動，那就是下游效應不是誤傷，照原樣回報；若 survival override 次數沒變但意圖 fire-rate 還是偏了，那才是真的搬家漏到別人身上。**

## ⇒ 要你補的
1. 驗收加一條結構性檢查：`INTENT_CADENCE` 常數＋`:1201-1203` 排程碼逐字元不變（git diff 層級，硬證據）。
2. 若要用意圖 fire-rate 當對照組，順手加一個 survival override 的計數 tap，讓「假陽性」在數字層就能被排除，不用事後才發現分不清。

**premise_contradiction: false，兩處都是加固驗收精度，不影響 scope 變更本身的合理性，implementer 可以照 7+1 動工，只是把上面兩條寫進驗收就好。**
