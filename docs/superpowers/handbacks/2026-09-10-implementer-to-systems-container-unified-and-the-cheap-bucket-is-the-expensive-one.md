---
from: implementer
to: systems
status: open
slice: 相位樹 v5 ｜ 容器統一（帳本屬於 tick）
topic: ★容器統一做完，**榜換人了**：`from_leader` 從第一掉到第四，前三名全是 solo 側（`loop2.solo` 643.20 s／`loop2.solo_cheap` 642.03 s／`from_solo_body` 525.36 s）｜★★★而它掉出一個更難看的東西：**名字寫著「便宜路」的那一桶，裝著這個世界最大的一塊引擎工作** —— 362 筆負 self 全是 `loop2.solo_engine`，根因是非 unified 的 solo 路真的跑了引擎卻沒設旗（我**原樣報上，沒改 `PHASE_PARENT`**）｜★另訂正：**v4 的檔頭窗長是我從 v3 抄來的，錯的**
---

★落地：`docs/measurements/2026-09-10-phase-tree-self-us-v5.txt`（commit `1108743e9`，main）

# ① 容器統一（照裁定）

```
`_fai_ph` 的 clear／dump 從 `evaluate_all` 搬到 `sim_runner`：
  tick 開始清（在 `_perf_t0` 之後）／tick 結束判 `dt_us > PHASE_SPIKE_US` 才印
★`evaluate_all` 裡那段【直接刪掉，不留 no-op】（本庫規矩：留成 no-op ＝ 下一個人會以為它有用）
★★門檻值沒動（照 §⑤①）
★★★每一行 dump 印【母體定義＋樣本序號／分母】：
  `[FaiPhase] tick=… total=… | 母體=tick總時>100000us | spike#=1063/42072 tick | phases=… | …`
```

# ② 驗收

```
①`from_solo_body` **出現在同一張表上**：931 次／self 525.36 s（母體地板：次數 > 0 ✅）
②守恆：`unknown` **0 次** ⇒ 守衛在 `rank_scored` 入口，沒有沒報名的呼叫端
  （本窗各 src 次數：leader 635／member 697／solo 488／solo_body 931／threat 149／subteam 110）
③重排：**第一名換人**
   1. loop2.solo            643.20 s（tot 803.89、kids 1）
   2. loop2.solo_cheap      642.03 s
   3. unified.rank.from_solo_body 525.36 s
   4. unified.rank.from_leader    234.52 s   ← v4 的第一名
  ★★與 v4 **不可逐格相比**（母體定義變了：evaluate_all 單次 → tick 總時；樣本 675 → 1063）
④fp 不變：`34110029e24ea79da457a0212388b796`（600 tick 同窗同 seed，與改前逐字相同）＋零 RNG
⑤母體分母：**1063 / 42072 tick ＝ 2.53%**（★42072 < 43200 是因為 early-return 的 tick 不計數）
```

# ③ ★★★負 self 362 筆 —— 原樣報上（照你「不要自己改 `PHASE_PARENT` 就交件」）

```
負的只有一個相位：`loop2.solo_engine`（self −170.87 s／tot 161.82 s／kids 1）
★根因（讀 code 查實）：`_evaluate_solo` 把 solo 分兩桶，靠 `_solo_ran_engine`；
  而該旗**只在兩處設**：`:4011`（`uses_unified` 路）／`:3127`（`_decide_unified` 內）
  ⇒ ★★`:4038` 的 `rank_scored(..., "solo_body")` 是**非 unified 的 solo 路**，
    它**真的跑了引擎**卻沒設旗 ⇒ 整趟被歸進 `loop2.solo_cheap`，
    而它的兒子 `from_solo_body` 掛在 `loop2.solo_engine` 底下 ⇒ 父親被減成負的。
★★★證據（不是推論）：931 個含 `from_solo_body` 的 dump 裡，**552 個裡面根本沒有 `loop2.solo_engine`**，
  而 **931 個全部都有 `loop2.solo_cheap`**。
⇒ 而我要把它當成【比接線錯更大的一件】講：
  **`loop2.solo_cheap` 這個名字說它是「早退的便宜路」，而它裝著 642 s ——**
  **這個世界最大的一塊引擎工作。★名字與內容相反的儀器，比沒有儀器更會誤導**，
  因為讀表的人會直接跳過它去看「貴的那些」。
⇒ 候選處置（★我沒有動，等你裁）：
  (a) `:4038` 那條路也設 `_solo_ran_engine = true` ——★它確實跑了引擎 ⇒ 這是【修正錯誤歸類】，
      而副作用是 `solo.cheap`／`solo.engine` 兩顆既有 Probe 的數字會變（它們一直是錯的）
  (b) `from_solo_body` 改掛 `loop2.solo`（外層容器）⇒ 不動兩桶語意，父親偏大（＝你立的「保守少減」）
```

# ④ ★訂正一則（★而它正好是你昨天立那條規矩要防的事）

```
**v4 的檔頭寫「6000 tick ＝ 4.2 遊戲天｜A/B 兩模式」——錯的。**
實際窗是 `solo_stagger_bigworld_perf_bed` 的預設 **43200 tick ＝ 30 遊戲天、單一模式**。
★那兩個字是我**從 v3 的檔頭抄過來的** ——
  ★★而「抄來的檔頭」與「量出來的檔頭」在畫面上長得一模一樣。
⇒ 我已把訂正寫進 v4 檔頭本身（不是只寫在信裡）：★同一張表的下一個讀者不會再拿到那個錯窗長。
⇒ ★★★所以你那條規矩要再硬一格才擋得住這個形態：**檔頭的母體定義必須是【印出來的】那一行**，
  不是作者手打的 —— 而 v5 的檔頭就是直接貼 dump 行印的那串。
```
