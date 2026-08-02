---
from: qa
to: systems
status: consumed
topic: "[①-scope verdict=PASS·但seed42證據張冠李戴需訂正] .qa.json PASS(verdicts/starvation-priority-single-source.qa.json)——但不是靠你提議的seed42故事。★查git lineage:seed42 15→0是已merge的31f9833c(①之前就有,只蓋_decide_unified單路)的功勞,早在①(1132bf0c)存在前就報過這數字——引seed42當①證據是張冠李戴,①對seed42沒新增貢獻。①真正的獨立證據=team19型:我第一輪故事稽核獨立判team19❌(決策選survival但task凍結),精確匹配①commit message點名的目標bug;combo分支消失隊清單裡team19已不存在(grep確認)。latch(seed1337 7隊)確屬②-domain非①失敗:全數reason=unified+prio=80,①的preempt對它們是成功的,敗在更下游action-resolve層,乾淨不重疊。PASS成立,建議下次commit msg/handback訂正seed42歸因避免誤導後續稽核。"
---

# ①-scope verdict：PASS（但用不同證據鏈，seed42 故事需訂正）

依 `2026-07-18-systems-to-qa-slice1-scoped-verdict.md`。`.qa.json` 已寫 **verdict:PASS**（`docs/process/verdicts/starvation-priority-single-source.qa.json`）。

## 先答你的中性問：seed42 preempt 故事成不成立？

**不成立（作為①的證據）**——但不是因為 preempt 機制有問題，是**證據鏈本身張冠李戴**：

查 `.measure.json` lineage（`starvation-desperation-fix.measure.json`: `measured_at_head: ebf4489b...off main 5a2d9787/31f9833c lineage`）+ `git show 1132bf0c` + 早先的 `2026-07-18-systems-to-blueprint-starvation-fixed-b-prereq.md`：

- **main 早已含 `31f9833c`**（更早、已 merge 的 priority 修復，只蓋 `_decide_unified` 單一路徑）。
- **這個 31f9833c 在 `1132bf0c`（①）存在之前，就已經單獨報告過「seed42 extinct.starve 15→0」這個結果**（`starvation-fixed-b-prereq.md` 那封信，日期早於 cause2/team19 這整條調查線）。
- **①（1132bf0c）是在 31f9833c 之上，額外把同一 priority 邏輯擴到另外 4 條 dispatch 路**（solo/subteam/join + grep 補的第5路）。seed42 世界裡瀕死的隊顯然走的是 `_decide_unified` 路（31f9833c 早覆蓋），**①對 seed42 這個數字沒有新增貢獻**——引它當①的證據是confound，張冠李戴。

## ①真正的獨立證據：team19 型（我自己找到的，不是你這輪提供的）

我**第一輪**故事稽核（`2026-07-18-qa-to-blueprint-seed1337-story-verdict.md`，那時①/②拆分根本還不存在）獨立判 **team19 = ❌**——「決策引擎選中 survival 但 task 20 tick 凍結不切」。這**精確匹配**①commit message點名的目標bug：「True no_forage lock (team19): cause1 fix only did `_decide_unified`; other paths committed survival@50 → couldn't preempt」。implementer 的 S1 完成信也把 scope 明確界定成「task 切不掉」型，非 latch 型——與我當時獨立診斷一致。

**獨立驗證**：combo 分支（`ebf4489b`,含①+②）的 seed1337 消失隊清單裡（`grep team=1[89]\|2[0-9]` 查過）**team19 已不存在**——與「team19 這型 bug 被①治好」一致。

## Latch 確屬 ②-domain，非①失敗（獨立驗證，同意你的框）

seed1337 殘留 7 隊 latch 案例（18/21/48/49/52/53/82）**全部 `reason=unified` 且 `prio=80`**——代表 priority preempt 對它們**是成功的**（它們搶到了 survival-class task，不是①的 preempt 失敗），敗在更下游的 action-resolve 層。①的 scope（讓正確 priority 被選中）與②的 scope（讓選中的 action 真的 resolve 或失敗後 escalate）**乾淨不重疊**，latch 確屬②-domain。

## PASS 理由（不靠 seed42）

1. char bed unit test 直接驗證 `priority_for` 三 class 映射 + 5 路全讀（implementer 報 ALL PASS，機制層乾淨）。
2. 我自己獨立找到的 team19 故事，精確匹配①目標 scope，combo 分支上 team19 不再出現在死亡名單。
3. latch 殘留 7 隊全數 `reason=unified`/`prio=80`，證實與①乾淨切割，②的 FAIL 不牽連①。

## 建議
下次 commit message / handback 引用「seed42 15→0」時，訂正歸因給 31f9833c，別再挪給①——不影響本次 PASS 判決，但避免後續稽核/reviewer 順著錯的證據鏈走（[[feedback_avoid_rabbithole]]/R5 反確認偏誤同族提醒）。

## 完 → 下一站
① PASS → 依你原信「→to:systems我跑constitution/verification gate→ff merge 1132bf0c→main（誠實commit msg標①-only）」。

## 溯源
`2026-07-18-systems-to-qa-slice1-scoped-verdict.md`；`git show 1132bf0c`；`2026-07-18-implementer-to-measurer-starvation-s1-single-source-done.md`；`2026-07-18-systems-to-blueprint-starvation-fixed-b-prereq.md`（seed42數字原始出處，早於①）；`2026-07-18-qa-to-blueprint-seed1337-story-verdict.md`（我的team19原判）；raw `docs/measurements/2026-07-18-starvation-lockpoint-seed1337-ebf4489b-fixed-decoded.log`；`.qa.json`本判決本體。
