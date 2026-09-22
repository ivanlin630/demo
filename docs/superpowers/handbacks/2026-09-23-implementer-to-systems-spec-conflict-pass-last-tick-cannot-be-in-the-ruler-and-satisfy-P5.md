---
from: implementer
to: systems
status: consumed
topic: ★★★spec 內部衝突：§4a「兩個都必須進指紋」與 P5「樁關掉時指紋與世代 7 逐字相同」★不可能同時成立｜★★證據鏈在內（FpCoverage 的分類規則）｜★★★我有一個我認為正確的解，但那是設計決定 ⇒ 你裁
---

# ★一、衝突

```
§4a  「pass_next_tick／pass_last_tick ★兩個都必須進存檔與指紋」
P5   「★樁關掉時指紋必須與世代 7【逐字相同】」
```

⇒ **加任何一個新欄位進指紋，指紋就會變** ⇒ 兩條不能同時成立。

# ★★二、而機制比「加欄位就會變」更細，我逐層查過

指紋的 team 行有兩段：一段是手寫的 `buf.append("T|…")`，一段是
`_derived_line(t, "TD", "TeamData")` ⇒ 後者讀 `FpCoverage.fields_for("TeamData")`。

```
fp_coverage.gd:25  CADENCE_SUFFIXES = ["_eval_next_tick", "_next_tick", "_check_tick"]
⇒ ★pass_next_tick 命中 `_next_tick` ⇒ 【自動排除】，不影響指紋 ✓
⇒ ★★pass_last_tick 不命中任何後綴 ⇒ 落進 in_ruler ⇒ 【會進指紋】
```

★★★而「會不會進」還有第二道條件，它很細：`_collect()` 在掃原始碼時
**整行跳過輸出行**（`OUTPUT_MARKERS` 含 `Probe.`／`print(`）並**剝掉註解**。

```
⇒ 若 pass_last_tick 只出現在 Probe.／print( 那種行上 ⇒ 它不算「被讀」⇒ 不進指紋
⇒ 但只要有一行 `team.pass_last_tick = cur`（普通賦值行）⇒ 它就進指紋
```

★**而那一行是必須的** —— 不然這個欄位沒有人寫。
⇒ 所以「靠 Probe 行的豁免躲過尺」在這裡**做不到**，而且就算做得到我也不想那樣做：
**那是把尺改到做得到，不是把事情做對。**

★既有前例佐證分類是對的：`solo_think_next_tick` 排除、
★★而 `solo_think_last_tick` 與 `breed_progress_last_tick` **都在尺裡**（同一條規則）。

# ★★★三、我認為正確的解（★但這是設計決定，你裁）

```
★不要把 pass_last_tick 放進 TeamData。
理由：它的用途 spec 自己寫了 ——【量間距用】。它是【量測狀態】不是【世界狀態】。
  ⇒ 不變量⑦：記帳可以掛 Probe.enabled，語意不可以。
  ⇒ 把純量測欄位放進世界狀態，等於讓【量測改變被觀測物】（它會進存檔、進尺）。
做法：間距在 tap 那一側算 —— 用 FactionAISystem 那種 static Dictionary
  （team_id → 上次 pass 的 tick），只在 Probe 路徑上維護。
後果：存檔不帶它（★無所謂：它只餵直方圖，不決定任何行為）
  ⇒ ★pass_next_tick 仍然進存檔（它是真排程狀態），而它被 cadence 後綴自動排除在尺外
  ⇒ ★★P5 的「逐字相同」在構造上成立，不必逐欄辯論
```

# 四、另外兩個選項我列出來，但都不推薦

```
(乙) 把 pass_last_tick 改名成 pass_last_check_tick（命中 `_check_tick` 後綴 ⇒ 自動排除）
     ★不推薦：這是【為了躲過尺而命名】—— 跟「把 600 改大」同族，你今天才拒絕過一次。
(丙) 接受指紋會變，把 P5 改成「排除那兩欄之後相同」
     ★不推薦：那需要一個 fp 變體，而【尺有兩把】本身就是下一個人會踩的坑。
     ★★而且它會讓「重構有沒有改行為」重新變成要逐欄辯論的事 —— 正是 P5 想消滅的。
```

# 五、我現在在做什麼（不空等）

```
★我先寫【不依賴這個決定】的部分：
  ・pass_next_tick 欄位 ＋ 4b 的排程／到期形狀（>= 不是 ==）
  ・registry 的 grp 欄（12 整點／14 錯開，照 §3 的表，不憑 shape 推斷）
  ・_run_systems 的單一迴圈改法 ＋ 空批次 continue（在 _pht 之前）
  ・WorldState.pass_stagger_enabled 樁
★★間距 tap（P3）等你裁完再接 —— 它正是這個決定影響的那一格。
★★★①的電池還在背景跑，我沒有跑任何 Godot。
```

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
