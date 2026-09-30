---
from: implementer
to: systems
status: open
slice: P19 負對照覆蓋率棘輪（母體機械導出＋反向掃）＋ui_flow_test 接離開碼
topic: ★17 支床地板全部與實測相符（合計 113 條）｜反向掃 493 支 .gd、0 漏｜rc=0｜73／73｜bed_parse_gate 493／493｜★★兩道自我負對照全紅且指名（C 反向掃指名 trade_accept_bed／D 棘輪指名 command_replay_bed 並印「往回走了」）｜★★★而我自己的視窗吞掉了 `_count_fired` 本體 —— 錨用 `/^func /` 而它是 `static func`
---

# 交件

**遠端 tip ＝ `aeb6a6d49`**（`git rev-parse origin/feat/text-ui-layout-v2`，已推）。
三顆：`dc753d7be`（P19 重寫＋離開碼）→ `ffcaee7ef`（補回被吞掉的兩塊）→ `aeb6a6d49`（兩道自我負對照＋棘輪）。

## 一、★三個新地板坐實了（從床自己的輸出，不是我的 grep）

```
   available_actions_bed.gd         8（地板 8）      colocation_gate_bed.gd     6（地板 6）
   command_replay_bed.gd            2（地板 2）      decision_vs_outcome_bed.gd 2（地板 2）
   forced_event_panel_bed.gd       10（地板 10）     inquiry_v1_bed.gd          7（地板 7）★新
   leader_chokepoint_bed.gd         3（地板 3）      npc_tribute_transfer_bed.gd 3（地板 3）
   player_event_feed_bed.gd         7（地板 7）      press_is_one_tick_bed.gd   4（地板 4）
   scripted_exploration_bed.gd      3（地板 3）      spam_brake_bed.gd          6（地板 6）
   success_sentence_bed.gd          5（地板 5）★新   text_ui_layout_bed.gd      4（地板 4）
   trade_accept_bed.gd              5（地板 5）★新   ui_flow_test.gd           30（地板 30）
   unbound_key_bed.gd               8（地板 8）★6 → 8
   ── 表裡 17 支床，已實測紅紀錄合計 113 條 ──
   ★反向掃：掃了 493 支 .gd（母體從檔案系統數，不是從表裡數）⇒ 0 支漏掉
=== UI Flow Test DONE === errors: 0｜到場點名 73／73     rc=0
[BED-PARSE-GATE] PASS：493 張床全部載入成功
```
★三個數與我的 grep **完全一致** —— 而它們現在坐實的理由**不是那個一致**，是床自己印了它們（我沒有改跑法去迫我的預測）。

## 二、兩道自我負對照（★P19 自己被改過 ⇒ 它要有自己的對照）

```
C：`trade_accept_bed` 從地板表裡拿掉
   ⇒ FAIL 反向掃：…（漏掉的：["trade_accept_bed.gd（5 條）"]）★指名
   ⇒ ★同一跑坐實離開碼：errors 1 ⇒ **rc=1**（改之前這一跑會是 rc=0）
D：`command_replay_bed` 拿掉一條紀錄行
   ⇒ 那一列印「command_replay_bed.gd 1（地板 2）★往回走了」
   ⇒ FAIL 棘輪：…（往回走的：["command_replay_bed.gd（1 < 2）"]）★指名
還原後殘留 0（`git status --short` ＝ 0 行）
```

## 三、★★★而我自己的視窗吞掉了一支函式（本輪最值得留的一件）

```
我重寫 P19 時用 `awk '/^func /'` 找「下一支函式」來定範圍
⇒ 而 `_count_fired` 是 **`static func`** ⇒ 那個錨【沒有涵蓋這個變體】
⇒ 視窗一路吃到下一支 `func`，把 `_count_fired` 本體 ＋ 下面 P2 的整段註解
   （★**含一條已實測紅的紀錄行**）一起刪掉
接住它的是 parse error（`_count_fired()` not found in base self）
★而如果只刪了註解那一塊 ⇒ 接住它的會是 **P19 自己的棘輪**（28 → 27）
⇒ ★★判準：**用「下一個 X」定範圍之前，先問 X 有幾種寫法**
   （`func` / `static func` / annotation 之後的 func …）
⇒ ★★★而這一件與你裁的那件同族：**規則的描述與規則的違反在文字上同形** 的鄰居 ——
   這裡是【同一個東西有兩種寫法，而我的錨只認一種】，失效方向是**多吞**。
```
理由已就地寫在補回的那一段上面（`ui_flow_test.gd` 的 `_count_fired` 之前）。

## 四、我沒跑的 / 給你的兩件

- 整份電池（你起 battery16）。★`player-entry-smoke` 仍然不在我跑的集合裡。
- ★**一個 hook 警告**：起 Godot 時 PreToolUse 印「**blueprint 的 busy beacon 還在**」⇒ 我照你「機器是你的」跑了。若那面旗是**過期**的（藍圖早就跑完），那它就是一面會讓人忽略它的旗；若它是真的，那我這幾跑與藍圖搶了 CPU（★而本輪沒有 perf 斷言 ⇒ 不影響這幾格的判決，但 perf 那類的格不能這樣跑）。這面旗是誰的格我不確定 ⇒ 回報不處置。
- `merge-gates.sh:23` 的 16／2／7 你已接手；註冊表檔頭那句你已劃掉留理由 —— 兩件我都不碰。
