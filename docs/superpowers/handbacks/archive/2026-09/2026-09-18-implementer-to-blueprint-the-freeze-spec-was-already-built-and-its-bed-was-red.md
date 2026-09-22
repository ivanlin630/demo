---
from: implementer
to: blueprint
status: consumed
slice: UI 線第一件（凍結終線）｜**你派的那張 spec 已經落地了，而它的床是紅的**
topic: ★**開檔第一件事就撞到**：`2026-09-10-phase-tree-net-cost` 的東西**全部已在 main**（`PHASE_PARENT` 表、`phase_report` 含 `*multi` 不參與減法／未登記具名／三種成因並列，**以及兩支床**）｜★★★**而 `phase_tree_net_cost_bed` 有兩格是【紅的】**：它的錨寫死在 `faction_ai_system.gd` 裡找 `phase_report` 呼叫點，**而呼叫點早就搬到 `sim_runner.gd:144`** ⇒ ★**從搬家那天起就紅**｜★★**沒有人看到的原因是：這支床【沒有註冊成閘】** —— 跑它的只有手動｜★我修了錨＋把兩支床都註冊（`886c809b5`，expect 逐字對過）｜★★★**而「>2s 凍結幀歸零」那個交付【不在這張 spec 裡】** —— 它自己寫著「本票不優化任何東西」

# 一、現況（★我開檔查到的，不是推測）

```
scripts/simulation/faction_ai_system.gd
  :1063+  const PHASE_PARENT := { …（含 "*multi" 那一族：unified.to_task／gather.* 八支）}
  :1113   static func phase_report(ph, total_us, parent_map := PHASE_PARENT)
          ⇒ self_us 減法／*multi 排除／未登記【具名】／負值三種成因並列 —— ★全部都在
scripts/debug/phase_tree_net_cost_bed.gd      ⇒ 4 段、12 格
scripts/debug/phase_root_conservation_bed.gd  ⇒ 3 段（★跑起來是綠的）
```
⇒ ★**spec §②③ 的實作與驗收【都在】** —— **這一票不需要重做。**

# 二、★★★而它的床紅了兩格（★修前的輸出我留下來了）

```
[FAIL] ④找得到呼叫點（母體地板）
[FAIL] ④phase_report 只在 phase_timing 開啟時被呼叫（★關閉時零額外工作）
根因：床在 faction_ai_system.gd 裡找 `phase_report(_fai_ph`，而**呼叫點在 sim_runner.gd:144**
     （★那裡的守衛是對的：`if phase_timing and dt_us > PHASE_SPIKE_US and not _fai_ph.is_empty()`）
⇒ ★★**受測物沒壞，壞的是床的錨** —— 而床的錨壞掉時，它紅得跟「受測物壞了」一模一樣
```
★**我的修法不是把錨換成另一個寫死的檔名**（那只是把同一個病搬家）：
**改成【掃 `scripts/simulation/` 去找呼叫點】** ⇒ ★★**找不到才是母體地板（真的沒人呼叫）**，
**而守衛的內容不變：呼叫點必須在 `phase_timing` 旗標底下。**

# 三、★★為什麼它紅了那麼久沒人知道（這一格比修好它重要）

```
兩支床都【不在 merge-gates.tsv 裡】⇒ 只有手動跑才會看到 ⇒ ★沒有人手動跑
⇒ ★★這正是我們今天在別處講過的：**「床在」與「床會紅」是兩件事**
  —— 而這一支更進一步：**它會紅，只是沒有人在看。**
⇒ 我把兩支都註冊了（`phase-tree-net-cost`／`phase-root-conservation`），expect 逐字對過。
```

# 四、★所以「凍結終線」這件事的真實形狀（請你裁下一步）

```
spec 自己寫著：「★本票不優化任何東西：它讓那張表【變得可以排序】。」
⇒ ★★你要的交付（>2 秒凍結幀 ＝ 0）是【用那張表去挑、然後真的去修】——**那是別的票**
⇒ ★★★而我手上【現在就有】那張表能吐出來的東西：
     `[FaiPhase]` 會在每個 >PHASE_SPIKE_US 的 tick 印出 self_us 排序
```
★**我建議的下一步（兩選一，你裁）**：
```
(a) 我先跑一輪【凍結取樣】：warring_states 跑到出現 >2s 幀，把 self_us 前幾名與母體貼回來
    ⇒ ★那是「下一個要修誰」的答案，而不是我猜的答案（★成本：一輪世界跑）
(b) 或你已經知道要修哪一個 ⇒ 直接給我票，我做
```
★★**我預設 (a)** —— 理由是 spec §⑥ 自己記著的那件事：
**「今天連續四張票每一版都先挑了一個看起來最大的去優化，而前三個診斷後來都被推翻。」**

# 五、對帳

```
branch：feat/phase-tree-net-cost ＝ 886c809b5（origin 逐字相同｜未進 main 的 commit 數 ＝ 1）
內容：床的錨修正（12 格全綠）＋ 兩支床註冊成閘｜★production code 零變更
```
