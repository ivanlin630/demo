---
from: reviewer
to: systems
status: consumed
slice: 決策 tap 能對準「某一隊、某一段時間」
topic: R② ＝ **CLEAN**（`fcb9aeace`）｜三個自報弱點全核過，全部確認安全，無issue｜★一句流程提醒：這張是純 SendMessage 送審，沒有配一封 handback——這次我照常審了，但下次請還是補一封（哪怕只是標題行），不然這次的送審在 git 裡沒有留痕，之後有人想查「這張票是怎麼來的」會找不到
---

# 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "三個自報弱點逐一核過，全部確認你判斷正確，沒有一處需要改字。" }
```

# 核對

## (a) `_cmp` 今天真的沒有 team／tick 鍵 —— 窮舉過，不是 grep 一次就信

```
列出 decision_engine.gd 裡【所有】 _cmp[...] = 的指派（:331-444，14 處）：
  drive／weight／after_weight／coeff／after_coeff／fail_mult／after_fail／
  persist／final／terms／opt／authed／tier／loot_est／odds／value_est／blind／target
⇒ 沒有一個是 team／tick 或任何同義詞（team_id／tid／current_tick 都沒有）
⇒ 你的判斷對：取到樣本也分不出哪一隊、哪個時刻，①要做的事是真缺口不是多慮。
```

## (b) `team`／`state` 可能 null —— 核過：只在 debug 床才會 null，production 路徑不會

```
rank_scored_ctx 在 scripts/simulation/ 裡唯一的呼叫點：decision_engine.gd:106
  （`rank_scored` 內部直呼），而 `rank_scored` 的三個呼叫端（faction_ai_system.gd:3527,4322,4597）
  每一處都傳**真的** `team`（沒有 team 不會走到 rank_scored）
⇒ team==null／state==null 的案例**全部**在 scripts/debug/*.gd（dissolution_check 系列、means_end_s1_test 等），
  它們繞過 `rank_scored` 直接呼 `rank_scored_ctx` 做單元測試
⇒ ★而 `raid.composition`／`shelter.composition` 這兩個桶**只在 production 路徑上**被真正餵進有意義的樣本
  （debug 床雖然也可能技術上跑進同一行 `if opt == "掠奪":`，但那些床的場景通常不會剛好叫到「掠奪」
   且同時 Probe.enabled，就算叫到，寫 -1 也不會污染 P2 的「team==11」窗——-1 永遠過不了那個窗）
⇒ 你寫「null 時寫 -1，不准跳過」是對的防禦姿態：production 路徑永遠拿到真 team_id，
  debug 床的邊界情況寫 -1 也不會被 P2 的窗誤收，兩邊都安全。
```

## (c) fp 不變的預測 —— 結構上站得住，P1 先量是對的紀律

```
probe_stats.gd:113 註解逐字：「禁 reservoir（reservoir 需 randf＝違 observer-no-rng 鐵律）。純確定性。」
⇒ 整個 Probe 取樣系統已經是**明文承諾零 RNG** 的設計，`sample_window` 只是多一層字典比對
  （team_id／tick_min／tick_max 的數值比較），不會引入隨機性
`sample_mute`（:122）＋ `reset()`（:135-144）的註解確認：這類「本輪設定」本來就**不隨 reset 清空**，
  正是你要抄的那個先例的真實形狀 ⇒ `sample_window` 照這個模子做，形狀對。
⇒ Probe 的所有資料結構（samples／counts／amounts）都是它自己的 static dict，跟 WorldState 不共用記憶體，
  結構上沒有一條路能從「多記一次窗內外判斷」走到「改世界」。
⇒ 你還是把 P1 寫成「先量」而不是「我證明過了不用量」——這是對的紀律，我沒有更好的答案，核過一致。
```

# 其他核對（不在你自報範圍，但我核了基準）

```
基準樹 60e4e2fd5 是 HEAD 祖先；量測員信 sha 5b07829eb 存在 —— 都是真 commit，不是虛構引用。
CMP_DUMP_OPTS（decision_engine.gd:32）已含「掠奪」—— 確認上一張票（補領袖票②）已經落地，
  這張是接著它繼續做，不是建在一個還沒merge的東西上。
```

⇒ 下一站 ＝ 你派 implementer（排序你自己定）。
