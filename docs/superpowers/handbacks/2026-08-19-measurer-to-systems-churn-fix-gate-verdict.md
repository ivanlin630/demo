---
from: measurer
to: systems
status: consumed
topic: "churn-fix-gate-verdict"
---

# churn-fix gate 數字：核心機制TDD控制床實證PASS,組織性大窗②③④部分缺口

`measured_at_head: fd8c6d6e`（main）。數字全落地：`docs/process/verdicts/mergein-churn-fix.measure.json`（raw_logs 見內附路徑）。

## 摘要

**核心機制★證實**（非organic噪音,決定性控制床）：`mergein_join_lifecycle_test.gd`(seed=1337,T2 TDD)我獨立重跑,**ALL PASS**：
- 撲空abort：`join.abort_ghost=1`真fire、task釋放(非永久latch)、`join_rejected` memory寫入(cooldown內同host不可重選)、`social_target`清空——**同對隊churn換皮結構性不可能重演**(gate①非只觀察到降低,是構造上斷根)。
- timeout：`join.timeout=1`真fire(host追不到)。
- 不誤傷：host靜止可達→正常resolve、零false abort/timeout、真實merge發生(`[Merge] Team12←Team10 pop=33`)。

gate①⑤⑥ = **PROVEN**（控制床決定性、非organic噪音）。constitution PASS(77/0)、headless獨立完整跑清(0-new,7個已知FAIL+own_granary crash全對known_issues基線)= gate⑦ **CONFIRMED**。

## ★★attribution：確認pre-existing,非農業b專屬

plain main(b223a862,無農業b)partial跑(warring_states seed=1337,~day14前被GODOT_TIMEOUT殺)已顯churn signature：`SurvivalMergeIn Team70→Team37`重複3次+`→Team11`1次。code-read佐證：本fix只碰`faction_ai_system.gd`,不碰農業b任何檔。∴ **直接branch vs base main對照有效,不需疊農業b churn-rich條件**。

**QA:PENDING**——此attribution結論來自organic長跑partial數據,依規矩(★★餵QA-verdict機械閘)需specimen trace過QA故事稽核才能當因果結論鎖定。但★本gate的核心支撐是上面決定性控制床(非organic、非故事類、seed=1337 TDD pass/fail)，不受此閘管——attribution只是輔助佐證,非唯一支柱。

## ★缺口（誠實揭露,非隱藏）

1. **②churn消(resolve/commit比例)**：organic day35 checkpoint——branch(teams=133,commit=15/resolve=6=40%,timeout=1,abort_ghost=3)vs base(teams=129,commit=3/resolve=9=300%)。**base那個300%不是「比branch好」的訊號**——n=3樣本太小(呼應attribution：plain main天然churn量低,原1.4%數字來自農業b高壓698次commit的不同量級場景)。
2. **③team不暴增 / ④perf回正**：**未在農業b同量級高壓下獨立復現**（原49→242/793ms那個degradation規模）。organic day35兩邊都只到133/129隊,沒到原始那種爆量。
3. **兩次2mo organic跑的stdout都被工具bug吃掉**（見下)，只剩sidecar checkpoint,沒有原始print行可數「同對隊反覆次數」的organic版本——但control床已經結構性證明這件事,不依賴這個。

## ★★意外發現：`tools/godot.ps1` wrapper有race bug

`GODOT_TIMEOUT`觸發`Kill()`後立刻`[System.IO.File]::ReadAllBytes($tempOut)`——**被殺進程的stdout redirect handle還沒釋放**,擲`"being used by another process"`,整段stdout憑空消失(只剩sidecar這種側寫檔活著)。**複現2次**,一次併發run(可能歸咎併發)、一次solo run(排除併發,證實是通用timeout-kill race)。**建議另開票給你**——這會讓所有「跑很久、可能撞timeout」的量測都有隨機性失憶風險,非本次獨有。

## 我的判斷

gate①⑤⑥⑦=硬證。②③④=方向一致但未在原始高壓規模下坐實,屬**可選補測**非release blocker——決定性控制床已經是比organic聚合更強的證據(守`03b測量協議`:查因果>organic聚合)。你/blueprint要不要在此規模缺口上再等一輪農業b疊加高壓量測,還是機制證實已夠綠燈merge、缺口記known_issues跟labor-v2/農業b re-measure時一併看，你裁。
