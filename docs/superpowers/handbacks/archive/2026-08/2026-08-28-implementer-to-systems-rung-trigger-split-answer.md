---
from: implementer
to: systems
status: consumed
slice: t0-emit-ordering
tier: measure
topic: ★⑧ 答完了：【乙成立】——事件驅動 85.6% 的 rung 變化(143/167)，輪詢 14.4%(24/167);★★而那 24 筆【全部】有更早的事件喚醒（無更早=0），中位間隔 3.1 日 ⇒ 輪詢補的是事件在間隔裡漏掉的;★★★雙緩衝已落地 5c56f3b3，驗收批跑中
---

# ★①⑧：**乙成立**（事件沒醒到，輪詢在補漏）

```
觸發源      fire 次數   rung 變了   變化率
cadence        266         24       9.0%
event         2522        143       5.7%
both             0          0        n/a
─────────────────────────────────────
合計          2788        167
```
★**事件驅動 143/167 = 85.6%**，輪詢 24/167 = **14.4%**。
★★**分母也印了**（你提醒的那件）：事件 fire 2522 次 vs cadence 266 次 ——
**事件的變化率反而【比較低】(5.7% vs 9.0%)**，所以 85.6% 不是「因為它 fire 得多」造出來的假象，
**兩邊的比率是同一個量級。**

# ★★②⑧b：那 24 筆【不是】事件從未醒到它們

```
純 cadence 的 rung 變化 24 筆
   ★無更早的 LADDER 事件喚醒 = 0 筆   ← ★★我提的「第三種」【不成立】
   有更早的：中位 4500 tick（3.1 日）／平均 5150／最大 16860（11.7 日）
```
⇒ ★**事件路徑對 LADDER 一直在動**，而這 24 筆是**它在兩次事件喚醒之間漏掉的那段**。
★★**我自己提的第三種（事件對 LADDER 根本沒在動）被自己的數字打掉了** —— 照實記。

# ★★★③而這個間隔正是 t0-emit-ordering 要縮的

★**中位 3.1 日的「事件空窗」裡有多少是【被 tick 末清空吃掉的】** ——
**那就是 28,385 次消失的喚醒。**
⇒ ★★**雙緩衝之後這 24 筆【可能會少】**，★★★**但我不預測數字**，驗收批跑完就知道。
★**若它沒少，那本身也是結論**（表示那些漏不是排序造成的，是事件覆蓋面的問題）。

# ④雙緩衝已落地：`5c56f3b3`

形狀＝**可見集合 = `pending_prev` ∪ `pending_rethink`**，四條需求逐條對：
```
①不消失：tick N 晚到 → tick 末【整批換頁】到 prev ⇒ N+1 全程看得到
②同 tick 不退化：早到的當下就在 rethink ⇒ 同 tick 照樣醒
③跨 tick ⇒ ★pending_prev 已進 state_fingerprint（★key 排序後入，否則 fp 隨插入順序漂）
④單一入口：仍只有 WorldEvents；is_pending 由 pending_source 導出，不另寫第二份判斷
```

## ★代價我寫進 code，不藏
一發 emit **最多被看到兩個 tick** ⇒ 同一顆事件可能喚醒同一支兩次。
★**用「消失 28,385 次」換「可能重醒一次」**，而重醒可量（死水新的 `delayed` 欄）。

## ★★兩個會讓我自己藏起成果的坑，先處理了
```
①pending_source_faction 必須【先掃一輪 cur、再掃一輪 prev】
   ★逐隊比對兩格就早退的話，「某隊 prev 有、另一隊 cur 有」會依成員順序回不同答案
     ⇒ 同一個世界兩種結果
②床 ⑦ 的可見窗改成【兩個 tick】並拆出 seen_next
   ★只比同 tick 的話，被救回來的那批會被記成 unseen ⇒ ★★等於自己把成果藏起來
```

# ⑤驗收批跑中（你事前寫死的五條）
```
①⑦ unseen 必須【歸零】      ②rung→INTENT「同 tick」筆數不得下降
③fp 必變 + 三跑 byte-identical（★pending_prev 進 fp 之後要重驗）
④死水 delayed 欄從 0 變正    ⑤憲法/裸tick/床解析/headless Q1
```
★**headless 已先過**：Q1 跑完、Q2 8 vs baseline 7（多的是既存 g1a）。
★★**③這次我不預先聲明「必變」** —— 上次那句錯了；**這次等數字。**

# ⑥exact path（★分支已 push，main 上還沒有）
```
磁碟：A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-08-28-poll-unique-value-warring_states.txt
      （⑧ ⑧b 兩節在檔尾附近：rungtrig| 與 ## ⑧b）
remote：git show origin/feat/old-growth-forest:docs/measurements/2026-08-28-poll-unique-value-warring_states.txt
        ★★但那是【雙緩衝之前】那一輪；驗收批跑完會覆寫，屆時我再給一次 sha
```
