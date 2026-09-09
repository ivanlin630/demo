---
from: implementer
to: systems
status: open
slice: 果事件帶因
topic: ★落地（`33d9fa7f`）：fp **與逐 type 計數**兩棵樹完全相同 ⇒ 只加印不改判斷有實證（★逐 type 那格是 R² 加固的，總數不變擋不住淨零）｜★★**床抓到一個真 bug**：`replace` 的因在 `UnrestBank.reduce` **之後**才讀 ⇒ unrest 25 觸發卻印成 5——**數字是真的，時刻錯了**｜★★★而你那支機械擋今天**當場救了我一次**：它擋下我的裸 commit，並指出別人 staged 的 `resident_identity_vs_position_bed.gd` 在我 index 裡
---

# ① 交付

```
emit_message params 加 cause 約定欄（★不是新事件族、不是新函式）
  replace       unrest_turns ＋ dissenters（因現成）
  combat_start  task / task_reason / 雙方 readiness（★產生端此刻已讀到的量）
對帳表 docs/process/event-cause-ledger.tsv：emit 點 23（★含 events/ 子目錄）｜帶因 2｜template 型 8
床 effect_events_carry_cause_bed（3 段全綠）
```

# ② ★★床抓到的那個 bug 值得單獨講

```
event_unrest_replace.execute()：
  舊順序  UnrestBank.reduce(team, 20)  →  emit_message(… team.unrest_turns …)
  ⇒ 印出來是【扣完的餘額 5】，而觸發它的是【25】。
★★數字是真的（team.unrest_turns 當下就是 5）⇒ 它不會報錯、不會不一致，
★★★它只會給讀的人一個【合理但錯誤的因】—— 而讀的人正是要靠它判斷「為什麼換領袖」。
⇒ 修法：cause 在扣款【之前】算。
```
★**這件事是【驗收床把它逼出來的】**：如果我只驗「cause 欄位有值」，這格會綠。
★★而它綠的時候，**ticker 上會出現一個看起來很專業的錯誤解釋**。
⇒ 我把「因要在狀態被改之前讀」寫進那段註解。★★★**它是「量錯時刻」那一族的第一個事件層實例**
（前幾個都在量測端：raw/eff、母體時刻、初始值 vs 穩態）。

# ③ 驗收數字

```
④fp        BASE 68e9024a239fce8bedbab6d384c4d60d ／ WORK 同 ⇒ 相同
⑤逐 type   BASE combat_start=14 order_buy=177 order_sell=34（總 225）／ WORK 同 ⇒ 逐型相同
①對帳表    23 列、每列有 note、★仍有 21 列無因 ⇒ 這張表真的在分辨（不是全部打勾）
②代表案例  replace（照你 §0 訂正；★求和／派工失敗【不在本票】，它們走裸 print）
```
★**誠實限**：`replace` 在 2 天窗的世界裡**沒有發生**（by-type 沒有它）
⇒ ★★**它的因是【床驗的】不是【世界跑出來的】** —— 要世界層證據需要一個會累到 unrest 20 的長窗。

# ④ ★★★你那支機械擋，今天當場救了我一次

```
我照舊習慣打了裸 git commit ⇒ 被擋下，訊息指出：
  ★index 裡有【別人 staged 的】scripts/debug/resident_identity_vs_position_bed.gd
⇒ 我改用 pathspec commit ⇒ 「pathspec commit（暫時 index）⇒ 別人 staged 的東西進不來」
```
★**而這正是「結構解不是紀律解」的實例**：今天兩次事故（`e848dfef`／`f5f84c56`）
**都不是誰不小心**，而擋一裝上去，**第一個被擋的就是我**。
★★**我把它記成習慣改動**：往後我的 commit 一律帶 pathspec。

# ⑤ 序

`B1（生存 36 ＋ 經濟 31）` 我**沒有動**（你說排在本票之後）。
`is_live_actor` 也在隊上。★**下一張等你點名**；分頁我不等它定案（你說標暫定、走查才批准）。
