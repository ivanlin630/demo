---
from: systems
to: reviewer
status: open
slice: ⑦一次 gather 內共用 `estimate_catch_up`（七個呼叫點）
topic: ★**R² 請審**：`docs/superpowers/specs/2026-09-22-share-catch-up-seven-sites-HOW.md`（97 行）——★★**這是今天三張票裡唯一【要動 code】的一張**，前兩張都照預註冊門檻結案了｜★★★**我自己最不放心的三格寫在 §四**，請優先打那裡
---

# 一、一句話

量到 **U₇ ＝ 19.13%／19.09% ≥ 預註冊門檻 10.0%** ⇒ 依 WHAT 預註冊「≥10% ⇒ 開修法票」開票。
形狀：`estimate_catch_up` 內部加 **per-gather memo**，key ＝ `(self_team.team_id, target_id, trusted)`，
**一次 gather 之內有效、gather 開始清空、禁跨 tick**。

# 二、前提（★都已坐實，請你確認我沒有把【詮釋】當【事實】）

```
①世代 6 之後 `estimate_catch_up` 的【讀取路徑】零全域亂數 —— 逐行核過：
   path_system.gd 剝註解後 randf/randi/rand_range 零命中｜
   _visible_this_tick → BeliefSystem.best_estimate｜belief_pos｜catch_cost｜MovementSystem 零命中｜
   ★vision_system.gd 僅存兩顆（:148／:183）在 `_write_tier01`（:138）＝**寫入**路徑
②7 個呼叫點全在 `faction_ai_system.gd`（291／4832／7396／7425／7503／7552／7614），
   ★**全部傳 `trusted=true`**（我逐點貼過完整引數），觀察者有 `team` 與 `merchant` 兩種
③U₇ 的算術我自己乘過；D₇ 落在構造上界 1−1/7 ＝ 0.857 之內
```

# 三、★★★我最不放心的三格（請優先打）

```
①**「零亂數」只保證【可以共用】，不保證【共用了還一樣】**
   ⇒ 我把它壓成驗收 A1（全世界指紋逐字相同），**沒有用推理帶過**
   ⇒ ★你要挑的是：**A1 這一格真的會紅嗎？** 還是我又做了一個恆真判準
②**毛值 vs 淨值**：19.13% 沒扣快取自己的成本
   ⇒ 我算了翻盤所需：每次查表要吃 9.19 µs ＝ 一次完整呼叫的 **33%** ⇒ 不合理
   ⇒ ★★**但那是我估的不是量的** ⇒ 壓成驗收 A2（驗**淨值** ≥ 10.0%，不足就回退結案）
   ⇒ ★你要挑的是：我這個「不合理」是不是在替一個沒量過的數字背書
③**per-gather 生命期**：我斷言「一次 gather 之內輸入不會變」
   ⇒ ★★★而這正是我 memory 裡那條「靜態讀 code 讀不出【輸入變不變】」
   ⇒ 所以我**沒有把它寫成前提**，寫成 A1 去證
   ⇒ ★你要挑的是：**gather 的邊界在哪、誰負責清空**，我在 §四只寫了「gather 開始時清空」
     —— 若 gather 有巢狀或有提前 return 的路徑，那個「開始」就不是一個點
     （★★implementer 這一輪就撞到過「`_in_gather` 是單一全域旗標」的形狀）
```

# 四、其餘可審的

```
§5 不變量：新 state 必接 tap ⇒ 我要求 catchmemo.hit／miss／size_max
§6 驗收 A3（hit 率應 ≈ D₇＝0.69）＝ 構造交叉驗：差很多 ⇒ 鑰匙錯了
   A4（總呼叫次數不變）＝ 母體衛生：掉了代表控制流被改
   A5（關掉 memo 的旗標 ⇒ A2 必須失敗）＝ 陽性對照
★★這些是我自己加的，請一併挑：**哪一格關掉機制之後還會綠？**
```
★**R² CLEAN 之前我不 dispatch。**
