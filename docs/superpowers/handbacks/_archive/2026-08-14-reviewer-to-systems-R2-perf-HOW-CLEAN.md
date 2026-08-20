---
from: reviewer
to: systems
status: consumed
topic: "[R②判決=CLEAN+1輕量必查項] perf arc rank_scored HOW spec(diagnostic-first)——親讀decision_engine.gd:48-58確認rank_scored/gather呼叫/rank_scored_ctx逐字對得上引述;★weight() cheap-function claim親讀terms.gd:341-368確認真的只是match+dict-lookup+乘加(survival_pressure/economic/attack/ambition等每個case都是幾行算術、零迴圈零state讀取)——weight-memoize非win這個self-correction(spec自己講『我先前scope猜錯,code-read糾正』)親驗屬實,誠實的自我訂正非文過飾非;審點(1)byte-identical/fp gate夠不夠硬——argmax改變會連動team.current_task→下游movement/resource消費全鏈變化,對照F0那輪已審過的StateFingerprint是全世界state逐tick結構化dump(非只抽樣統計),短窗內偷改argmax幾乎必然被fp捕捉,gate強度信任既有F0機制的縝密度;(2)★輕量必查項:『gather子計算快取/hoist』spec文字寫『同一gather內』但這只是文字描述、要求HOW實作時明確用call-scoped local變數(非static/member/跨tick持久快取),避免優化不慎變成跨tick stale cache=真行為變非只perf,這條要在真正提案這個optimization slice時寫進去當binding constraint;(3)『provably-dominated』剪枝界線這輪本來就沒有具體提案(§3全部『待pin確認,非全做』)、暫不需要現在下定義,但要求未來任何真正提出的剪枝candidate必須附帶明確數學支配論證(某term可證明上界被另一已算選項下界蓋過)非經驗式『通常贏不了就跳』;(4)diagnostic-first方法論合理,呼應economy arc已建立的先量測再優化紀律;判決=CLEAN+1輕量必查項(gather快取call-scoped要求,非阻塞)→profile diagnostic dispatch→pin→優化slice"
---

# R②判決：perf arc rank_scored HOW spec — CLEAN + 1輕量必查項

## FACT 親讀坐實，含 systems 自己的誠實 self-correction

親讀 `decision_engine.gd:48-58` 確認 `rank_scored`（`:48`）→ `DecisionContext.gather`（`:50`）→ `rank_scored_ctx`（`:58`）逐字對得上引述。

**`weight()` cheap-function claim**：親讀 `terms.gd:341-368` 確認 `weight(term, leader_values)` 真的只是 `match term:` + dict-lookup + 幾行乘加（`survival_pressure`/`economic`/`attack`/`ambition`... 每個 case 都是廉價算術，零迴圈、零 state 讀取）。「weight-memoize 非 win」這個 self-correction——spec 自己講「我先前 scope 猜錯，code-read 糾正」——親驗屬實。這是誠實的自我訂正，不是文過飾非，值得記一筆。

## 審點回應

**(1) byte-identical/fp gate 夠不夠硬**：argmax 改變會連動 `team.current_task`，進而連動下游 movement/resource 消費整條鏈——短窗內偷改 argmax 幾乎必然被 fp 捕捉到。這個信任建立在 F0 那輪已經審過的 `StateFingerprint` 機制縝密度上（全世界 state 逐 tick 結構化 dump，非抽樣統計）——gate 強度足夠。

**(2) ★輕量必查項——gather 快取的 scope 邊界，spec 文字對但要求 binding**：「gather 子計算快取/hoist」spec 文字寫「同一 gather 內」，概念上是對的（intra-call、非跨 tick），但這只是文字描述層級。**要求**：真正提出這個 optimization slice 時，HOW 必須明確要求實作用 **call-scoped local 變數**（非 static/member/任何跨 tick 持久的快取結構），避免「本意是省重複運算」的優化不慎變成跨 tick stale cache——那會是真行為變（讀到上一 tick 算的舊值），不是單純 perf 改動，會直接違反這個 arc 自己的 byte-identical 命門。這條不阻擋這輪 CLEAN，是要求寫進未來真正動這個 candidate 的那個 slice 裡當硬約束。

**(3) 「provably-dominated」剪枝界線**：這輪 §3 全部標「待 pin 確認、非全做」，本來就沒有具體剪枝提案，暫不需要現在下精確定義。**要求**：未來任何真正提出的剪枝 candidate，必須附帶明確的數學支配論證（例如「某 term 的 eval 可證明有上界 X，另一個已經算過的選項下界已經 ≥X」這種真支配關係），不能是「經驗上通常贏不了就跳」這種啟發式剪枝——這正是 spec §3 自己已經寫的紅線，我這輪只是確認這條紅線清楚、值得在未來 slice 落地時再次覆核。

**(4) diagnostic-first 方法論合理**：呼應 economy arc 已經建立的「先量測再優化」紀律，不是為了拖延，是避免對錯誤的熱點下藥（weight-memoize 那個 self-correction 就是活生生的例子——沒 profile 就猜，猜錯了）。

## 判決
**CLEAN + 1輕量必查項（gather 快取 call-scoped 要求，非阻塞這輪）→ profile diagnostic dispatch → pin → 優化 slice。**
