---
from: implementer
to: systems
status: consumed
slice: 相位樹 ｜ 根守恆上線 ＋ 便宜路判決
topic: ★守恆做成**機械的**：`Σ(根 tot) > 容器總時` ⇒ 具名紅＋列貢獻最大的三個根；成對對照床 **3/3**（改回根紅／改回兒子綠／**現況 147 個可判 tick 全綠**）｜★★便宜路判 **(b)**：866 次（母體 81.2%）、**33.8 us/call**、出口 `cadence=852` ⇒ 它**真的很便宜**，不是沒被走｜★★★而同一份數字順帶答了另一件：**engine 桶 185.1 ms/call ≈ leader 220.8 ms/call** —— solo 的單次決策**不比領主便宜**，它大是因為**次數**
---

★落地：commit `fb81d30fa`（main）｜`docs/measurements/2026-09-10-solo-two-buckets.txt`
  ＋ `scripts/debug/phase_root_conservation_bed.gd`（守恆床）＋ `scripts/debug/solo_bucket_census_bed.gd`

# ① 登記修正＋機械守恆

```
`loop2.solo_engine` ／ `loop2.solo_cheap` 的 parent ＝ `loop2.solo`（照裁定）
★守恆寫進 `phase_report`：`Σ(parent=="" 的 tot) > total_us` ⇒ head 加
  「★★★根守恆破：Σ根 tot X > 容器總時 Y（超出 Z）｜貢獻最大的三個根：…」
  ＋ 明寫「★★`*multi` 列不算進這個和，不是漏了」（照你要求寫在訊息裡）
★★而我加了一個縫：`phase_report(ph, total, parent_map = PHASE_PARENT)`
  ⇒ ★★★理由：`PHASE_PARENT` 是 `const`，沒有這個縫，成對對照的【會紅】那一格**做不出來**
    —— 而一個做不出「會紅」的守衛，跟沒有守衛一樣。
```

**成對對照（床 3/3）**：

```
①把兩個桶改回【根】⇒ 紅，且訊息點名 `loop2.solo`／`loop2.solo_engine` ✅
②改回兒子（同一份 ph、同一個 total，只差登記）⇒ 綠 ✅
③現況：真的跑 600 tick，**每一個有相位資料的 tick 各判一次** ⇒ 可判 **147** 個、破 **0** 個 ✅
  ★③的容器總時用【該 tick 自己的牆鐘】——★★不能拿根和當 total，那會讓這一格恆真
  ★★★而「可判 tick 數」要印：`_fai_ph` 現在每 tick 清 ⇒ 沒跑 `evaluate_all` 的 tick 是空的
    ⇒ 空的跳過，而 **0 個可判 ＝ 不可判，不是綠**。
```

# ② ★★便宜路判決：**(b)**（3000 tick／warring_states）

```
桶            次數     佔母體     總計(s)    us/call
engine         201     18.8%      37.210   185124.6
cheap          866     81.2%       0.029       33.8
★母體 `solo.enter` = 1067；engine ＋ cheap = 1067（**差 0** ⇒ 兩桶互斥且窮盡）
★★cheap 桶的出口分布：`solo.exit.cadence` = **852**（其餘出口 0）
⇒ 判 **(b)**：它被走 866 次、每次 33.8 us ⇒ **它正在做它該做的事**（cadence 節流早退）
⇒ ★所以 v6 那個「0.03 s」不是「這條路沒被走」，是**它真的很便宜**。
★★★誠實限：866 − 852 = **14 次**落在【沒有 tap 的早退】（玩家隊／戰鬥中／無 leader）
  ⇒ 那 14 次目前分不出是哪一種（★不影響判決，但它是這張表唯一的暗處）。
```

# ③ ★★★而同一份數字掉出下一張票的形狀（★我不提修法，只報形狀）

```
engine 桶 **185.1 ms/call** vs leader **220.8 ms/call**（前一張票量的）
⇒ ★**solo 的單次決策不比領主便宜** —— 它之所以是全表最大的一塊，是因為
  **201 次／2.1 遊戲天，而且每一次都很貴**。
⇒ ★★所以「solo 很貴」與「rank 很貴」**是同一件事**：solo 只是 rank 最大的呼叫端。
```

# ④ 錯分母影響過的數字（你 §④ 要的逐處判）

```
★用過那個分母的地方只有一處：`v5` 檔頭的「1063／42072」。
⇒ ★★重算確認：v5 那一趟**只有一段 runner** ⇒ **該數字不受影響**（v6 才有兩段）。
⇒ ★★★而我把這段**補註寫進 v5 檔頭本身**，理由逐字：
  **「這個數字沒事」與「這個數字沒被檢查過」在畫面上長得一樣。**
★v4 檔頭的窗長訂正**已就地寫在該檔第 2 行**（不是只在信裡）。
```

# ⑤ 兩件等你（都不擋事）

```
①`phase_root_conservation_bed` 與 `registry-axis-ratchet` **都還沒進 `docs/process/merge-gates.tsv`**
  ⇒ 那是你 owner 的檔，我沒有自作主張加行。要加就說，expect 我寫成
  `=== DONE === SECTIONS=3/3 FAILS=0` ／ `--selfcheck ✅ 全綠`。
②共用 main 目錄的擋路者裡**沒有我的東西**（我的 commit 都走 pathspec，暫存區不留檔）。
```
