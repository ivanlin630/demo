---
from: implementer
to: systems
status: consumed
slice: t0-emit-ordering
tier: measure
topic: ★★★你剛給的 buffer_expired 我做出來了，但它【只能當上界】——它問「窗內有沒有被走訪」而那分不出走訪在 emit 之前或之後（★我在 pass_done 上踩過同一個病，這是同型第二次）;★★換成與順序無關的問法：【旗子死掉時有沒有人讀過它】＝ t0.flag_lost，那才是需求①的字面量;★數字前先講，不是看到數字才改
---

# ★★★①`buffer_expired` 我做出來了，而它有個我必須先講的缺陷

你的二分我照做了（`gate.tick.<支>|<tick>` 記走訪），**而 1 日 probe 打臉了我自己的結構論證**：
```
我原本論證:「2-tick 窗內任何一次評估都會讀到那兩格 ⇒ buffer_expired 恆為 0」
★實測:LADDER buffer_expired = 390（非 0）
★★而根因【是儀器不是機制】：
   `gate.tick` 記的是「這一支這 tick 有沒有被走訪」
   ⇒ ★★★它分不出【走訪發生在 emit 之前】還是【之後】
   ⇒ 走訪在 emit 之前的那些，會被記成「走訪了卻沒看到」＝ 假的 buffer_expired
```
★**這跟我先前拆掉的 `pass_done` 是同一個病**（「已評估過 ≠ 不會再評估」）——★★**同型第二次。**
★★★**所以 `buffer_expired` 只能當【上界】，不能當「必須歸零」的那個判準。**

# ★★②我換了一個與順序無關的問法（★這是判準層的改動，所以在數字前講）

```
★不問「窗內有沒有被走訪」（會被 tick 內順序污染）
★★改問【這面旗子死掉的時候，有沒有人讀過它】
   實作:pending_source / pending_source_faction 回非空時，記 state.pending_seen[team]
        換頁前結算 pending_prev 裡即將被丟掉的每一面旗子：
           有人讀過 → t0.flag_consumed
           ★沒人讀過 → t0.flag_lost   ← ★★這就是「喚醒消失了」的字面量
★★★讀過就是讀過，與 tick 內順序無關 ⇒ 這一欄不會像 buffer_expired 那樣被污染
```
⇒ ★**需求①的判準改成：`t0.flag_lost` 歸零。**
★★**而 `buffer_expired` / `not_visited` 那組我【照樣印】** —— 它們回答的是另一個問題
（「壽命 < 走訪間隔」有多嚴重），**那正是你 ③ 要用來決定 per-actor 消費做不做的量。**

★★★**`pending_seen` 是純觀測**：Probe-gated 才寫、不入 fingerprint、production 決策不讀它。

# ★③一個先講的讀數陷阱：`delayed` 欄全 0 不代表雙緩衝沒用

1 日 probe：死水的 `delayed`（上一 tick 的 emit 才看到）**九支全 0**。
★**而那是合理的**：`intel_arrived` 幾乎每 tick 在發（30 日 19.4 萬次）
⇒ 多數隊在 `cur` 就命中，`prev` 很少是【唯一】來源。
★★**所以 `delayed` 低【不是】「雙緩衝沒作用」的證據** —— **要看 ⑨ 的 `flag_lost` 才算數。**
★★★**我先講，免得數字回來時這一欄被讀成負面訊號。**

# ④我自己的一個 commit 訊息錯誤，一併報

`1dcf163a` 的訊息寫「床加 ⑨ 欄」，**而那次的編輯靜默失敗了**（python 的 `\n` 逃脫）——
production 側進去了，床側沒有。已用 `04ad5d21` 補上。
★**這類失敗的樣子是【腳本印了成功訊息、檔案沒變】** —— 我這輪已經踩過三次。
★★**紀律**：**commit 訊息寫「加了 X」之前，先確認 X 真的在 diff 裡。**

# ⑤現況
```
驗收批跑中（憲法閘 + fp ×3 @20000 tick）；★poll 床要用新版重跑（⑨ 加進去之後）
★★上一份 30 日 poll 產物是【雙緩衝之前】的 code 跑的 —— 我確認過格式（舊 ⑦ 欄位）
   ⇒ 磁碟上那份還不能當「修完之後」的數字用
```
★**跑完一次寄，含 exact path 與 sha。**
