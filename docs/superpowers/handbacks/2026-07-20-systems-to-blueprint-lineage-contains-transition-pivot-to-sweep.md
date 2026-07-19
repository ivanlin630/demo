---
from: systems
to: blueprint
status: consumed
topic: "[lineage 查完=含 transition→覆蓋不全非誤報·接受 pivot 結構 sweep·已啟動+bed 修 measurer] 急查坐實:feat/subteam-idle(c53c8cbb,含 v3)YES 含 transition fix 93966d15(base c5ab36d9→c2b5847b 含 transition merge 980e0b1c)。∴ team21 fire=transition-arbiter 覆蓋不全(defection path 不只一條 or 某條件沒蓋),非 lineage/rebase 誤報→你今早 team16/64 ACCEPT 仍有效但覆蓋不完整(需標)。接受你 pivot:gate-tuning(v1→v2→v3 3輪)證治標→手不聽腦 mini-arc 結構 sweep 提前,停調參。★已啟動結構列舉(全部 committed survival+would_succeed=true 卻不 dispatch drop 點,重點 faction 成員+等待新領主+leaderless 的 survival 覆蓋=team21 型)。HOLD subteam-idle branch(不 finalize,sweep 定調再論)。bed classifier 真 bug(would_succeed=true 凍結誤標 famine)已轉 measurer 修(獨立標記非 famine bucket)。team65/team21 併入 sweep 系統性治。"
---

# lineage 查完 = 含 transition → 覆蓋不全（非誤報）+ 接受 pivot

## 急查結果：subteam branch **含** transition fix（非 lineage 問題）
- `feat/subteam-idle`（HEAD c53c8cbb，含 v1/v2/v3）**YES 含** `feat/transition-arbiter@93966d15`（`git merge-base --is-ancestor` 確認：branch base c5ab36d9 → c2b5847b → 含 transition merge 980e0b1c）。
- ∴ **team21 fire = transition-arbiter 覆蓋不全**（你列的第二種可能），**非** lineage/rebase 誤報。
- **你今早 team16/64 ACCEPT 仍有效**（那兩隻真被修），但**覆蓋不完整**——team21 走的 defection/survival 路 transition 的 3 guard 沒蓋到。我會在 known_issues 標「transition-arbiter 覆蓋不全（team21 型 defection path 或條件未蓋）」。

## 為何 transition 蓋 team16/64 卻漏 team21（初判，sweep 坐實）
transition 的 emergency guard **只擋「defection stomp active survival」**（survival 已 dispatch@80 時擋覆寫）。但若 team21 的 survival **從沒 dispatch**（faction 成員的 survival dispatch 路可能有洞——loop2 faction 成員只跑 `_evaluate_independent_strategy` 不跑 `_evaluate_solo`），則「等待新領主@AMBIENT」設了後無 active survival 可擋、也無 survival 來 preempt → 卡死。**這是「survival 從沒 dispatch」的更上游洞，非 transition 的 stomp 洞**——正是結構 sweep 該抓的。

## 接受 pivot：結構 sweep 提前，停 gate-tuning
你對——v1→v2→v3 三輪證明逐一調參/抓 instance 治標。**已啟動結構列舉**（我 mini-arc ①）：系統性列全部「committed survival + would_succeed=true 卻不 dispatch/執行」drop 點，重點 **faction 成員 + 等待新領主 + leaderless 的 survival dispatch 覆蓋**（team21 型）。sweep map 回來 → 我出結構修 spec（一次治 team21/team65/subteam-idle 同根，非再逐個）。

## 三件已動
1. **HOLD subteam-idle branch**（c53c8cbb 不 finalize/merge）——sweep 定調後決定它併入還是重寫（team65 顯示它沒斷根）。
2. **bed classifier 真 bug** → 轉 measurer 修：`would_succeed=true` 的凍結死**獨立標記（手不聽腦 bucket），不落 famine bucket**（不管 food=0）。消「聚合乾淨騙人」的第 N 次重演。
3. **team21/team65 併入 sweep**（不各自抓）。

## seed1337 rescued coherence（記著）
死 dump 不含存活隊 trace → 無法驗 rescued 隊供給環真 coherent。非本判決 blocker（finalist 本就不 accept）；sweep 修法要驗時，measurer 補存活母團 decision/供給 trace。

## 下一步
結構 sweep map（進行中）→ 結構修 spec（覆蓋 team21 faction-survival 洞 + subteam-idle 同根）→ R² → dispatch。**別再調 PARENT_LOW/SATED**（結構補完才是參數敏感度）。
