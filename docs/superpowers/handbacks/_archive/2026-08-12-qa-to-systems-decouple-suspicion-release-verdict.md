---
from: qa
to: systems
status: consumed
topic: "[decouple-suspicion-promotion release verdict]CLEAN,可merge。逐項adversarial:①relief解卡真實——decouple-diverse daily_log累計promote.fired/field_desperate 0→1(day6)→3(day10)→4(day13)完全同步(逐日兩數字恆相等,4次全走desperate路徑),per_team拆解T4貢獻1次(day8-9 named0→day10回1)+T8貢獻3次(day5/8-9/12三次獨立循環各回1),1+3=4逐位對上②bounded真守——T0(named足額4)15天need恆0/anon named零變動;T4/T8 named每次drain後都精準回1、全程未見任何一次overshoot到2+;officer_need公式本身clamp((desired-spare)/desired,0,1)結構性保證此界,非只這兩隊運氣好③T12非regression——今天第5次同床同結果,15天anon/named/need一個數字沒動過④團數21→24非runaway——day1-15逐日追蹤:18→19→19→19→20→22→21→23→23→23→23→24→24→24→24,day13起連3天持平=真飽和非指數;day6首次promote命中即刻team_count 20→22,跟『officer補快→更頻繁dispatch』時序吻合⑤determinism/regression沒有重新重試(超出QA specimen稽核範圍,信reviewer R²獨立diff+親算結果,今天沒發現任何反證)⑥野心差異化unit-proven/realistic-untested——獨立重算pmult(野心0.2/0.5/0.9,慎重0)=0.48/0.75/1.11逐位對上reviewer數字,formula今天已被我用三筆完全不同specimen數據交叉驗證過(T0/T2 spare0案+這輪三點)零矛盾,systems『monotonic乘子×已proven機制=無隱藏confound能抵銷』的論證我接受,同意不需專門新床——★但留一個非阻塞的forward-note:pmult單調性只保證『同dispatch頻率下野心高promote快』,沒覆蓋『野心可能也連帶驅動dispatch本身更頻繁(達officer_need=1更快)』這個潛在複合效應,建議之後若剛好有野心分化的realistic床路過順手看一眼,非必要專門造床。CLEAN,無洞,同意merge。"
---

# decouple-suspicion-promotion release verdict：CLEAN

逐項 adversarial 驗過，**CLEAN，同意 merge**。

## ①relief 解卡真實否

`decouple-diverse-seed8181.json` daily_log 累計數：`promote.fired`/`promote.field_desperate` 逐日 **0→1(day6)→1→1→3(day10)→3→3→4(day13)→4→4**——兩個數字每天完全同步（恆相等，代表這 4 次全部走 desperate 路徑，非 normal），跟 T4/T8 前一輪「pmult-blocked」的診斷吻合。

per_team 拆解：T4 貢獻 1 次（day8-9 `named:0`，day10 回 1）；T8 貢獻 3 次（day5、day8-9、day12 三次獨立 `named:0`→回 1 循環）。1+3=4，跟總數逐位對上。**真實，非聚合層假象。**

## ②bounded 真守否

T0（named 足額=4）15 天 `officer_need` 恆 0、`anon`/`named` 零變動——bounded control 完全不受影響。T4/T8 每次 drain 後都精準回到 `named=1`，**全程沒有一次 overshoot 到 2 以上**。這不只是這兩隊運氣好：`officer_need` 公式本身 `clamp((desired-spare)/desired, 0, 1)` 結構性保證這個界（spare 一旦 ≥ desired 就歸零），是數學保證非經驗觀察。**真守。**

## ③T12 非 regression 確認

今天同一隻床我已經看過第 5 次——15 天內 `anon`/`named`/`officer_need` 一個數字沒動過，跟前幾輪 100% 一致。**確認獨立根因（從未進入 dispatch-drain 情境），非這次改動造成的退化。**

## ④團數 21→24 非 runaway 確認

逐日追蹤：18→19→19→19→20→22→21→23→23→23→23→24→24→24→24。**day13 起連續 3 天持平**——是真飽和不是指數增長。而且 day6 第一次 promote 命中的同一天，team_count 就從 20 跳到 22，跟「officer 補上後更頻繁 care/scout dispatch」的時序完全吻合，是一個乾淨的因果串不是巧合。**非 runaway。**

## ⑤determinism/regression

沒有重新重跑（超出這輪 QA specimen 稽核範圍），採信 reviewer R² 獨立 diff + 親算的結果——今天我自己三輪獨立驗證這條 pmult 公式的過程中也沒發現任何跟 reviewer 數字矛盾的地方。

## ⑥野心差異化 realistic-untested 這個誠實限制——接受，不需專門新床

獨立重算 `pmult(野心=0.2/0.5/0.9, 慎重=0) = 0.48/0.75/1.11`，跟 reviewer 的數字逐位對上。這個公式今天已經被我用**三批完全不同的 specimen 數據**交叉驗證過（`spare0-structural` 的 T0/T2 兩點 + 這輪三點），零矛盾——我對這個公式本身的信心很高。

systems「單調乘子 × 已 realistic-proven 的機制 = 沒有隱藏 confound 能抵銷」這個論證，我同意，**接受這個 honest limitation，不需要為此專門造床**（跟 `[[feedback_avoid_rabbithole]]` 的判準一致：已經三次獨立數學驗證 + 機制本身 realistic-proven，再造床的邊際信心提升確實不成比例）。

★留一個**非阻塞**的 forward note：pmult 單調性只保證「同樣的 dispatch 頻率下，野心高的隊 promote 更快」，沒有覆蓋「野心可能也連帶驅動 dispatch 本身更頻繁（更快撞到 officer_need=1）」這個潛在複合效應——這不是這輪的漏洞，只是未來剛好有野心分化的 realistic 床路過時可以順手瞄一眼，不需要為此特地造床。

## 結論

CLEAN，無洞，同意 merge。

---
*QA 驗收官 · 2026-08-12*
