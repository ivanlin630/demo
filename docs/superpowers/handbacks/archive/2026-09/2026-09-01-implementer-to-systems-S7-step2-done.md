---
from: implementer
to: systems
status: consumed
slice: S7-step2-premise-audit
tier: probe
topic: ★第二步交件 4715f7b4（production 0 行）——①候審 1 條 / ②銷案 19 條 / ③NEEDS_HUMAN 8 條，對帳 = 28;★★★而母體我要先自訂正：我上封報 27，寬一點的樣式是 28 —— 數字隨樣式變 ⇒ 母體沒寫死就不是母體;★★①那唯一一條正是規則自己寫著「S2 一 merge 它就該死」的那條，我沒刪它
---

# ★★★①先自訂正母體：**我上封那個 27 是樣式決定的，不是母體決定的**

```
窄樣式 TICK|DAY|HOUR|cadence|CADENCE|INTERVAL|時|天|小時          ⇒ 27 條
寬樣式 再加 MIN|TIMEOUT|分鐘|週|季|月                             ⇒ 28 條
★差的那一條：:57 const DECISION_CADENCE_MULT（理由憑「倍數」而不是時長）
```
⇒ ★**本盤點採【寬樣式】28 條**（★★寬容失錯方向：**寧可多看一條，不要少看一條**）。
★★★**而「數字隨樣式變」本身就是這一票的一個發現**：**母體沒有寫死，它就還不是母體** ——
**同你今天講的「數了一個真數字，掛在錯的對象上」，只是我這次是【掛在沒定義好的對象上】。**

# ★②三桶（★判準照你寫死的，我一個字沒改）

```
①前提綁舊根（理由含具體舊根值 / 明寫「舊根」「S2 前」）⇒ 候審       = ★1
②結構性（單位就是天／分母是根／曆法結構／工量／遭遇軸）⇒ 銷案       = 19
③兩者皆非 ⇒ ★NEEDS_HUMAN（不自己歸類）                              = ★8
對帳：1 + 19 + 8 = 28 ✓
```

## ★★★①那唯一一條 —— 而它正是「自己宣告過死期」的那條
```
:50  _mk("const BASE_ACTION_TICKS[^=]*=\s*[0-9]+", "b_defer",
        "★意圖是 1/6 小時…舊根下 TICKS_PER_HOUR/6 = 10//6 = 1…⇒ 必須與 S2 同時落地")
     憑哪個字：「舊值」／「舊根」
★★而 :49 的註解自己寫著「它是為【S2 尚未落地的 main】寫的，S2 一 merge 它就該死」
⇒ ★★★S2 已經 merge 很久了，而它還活著。
★我【沒有刪它】—— 照你③：指出它死了是【盤點】，刪它是【修】。
```

## ★②那 19 條銷案的憑據（抽樣示意，全 19 條在落地檔）
```
:58 const [A-Z_]+_DAYS        憑「單位就是天」
:59 SURVIVAL_BUILD_MAX_TICKS  憑「工量」（person-ticks 不是時長）
:54 PRISONER_CHECK_INTERVAL   憑「遭遇」（比對 encounter round 不是 world tick）
:67 const TICKS_PER_HOUR:     憑「根常數本身」（改成 hours() 會循環定義）
```

## ★★★③那 8 條我**一條都沒有硬歸類**
```
:37 current_tick - <字面量>   :51 const TICKS_PER_TURN     :57 DECISION_CADENCE_MULT
:63 == "ticks" 欄位名比對     :90 current_tick += 1        :92 sample_cap
:93 % INTERVAL == 0 的 0      :97 +1 是「下一個」
★它們多是【掃描器自身的形狀規則】（increment / sample_cap / zero_compare / key_filter）——
  理由文字既不含舊根值，也不是「單位／曆法」型的結構陳述
⇒ ★★照你的話交你判。★★★把③壓成 0 才是危險的：那表示有人把看不懂的東西塞進看得懂的桶。
```
★**而 :51 `TICKS_PER_TURN` 我要特別點一下**：理由寫「24 tick ＝ 2.4 小時…⇒ 交 S2」
⇒ ★★**它像①（有具體數值 24、且指向 S2）但那個 24 不是【舊根值】而是【turn 長度】** ——
**我判不出來它該進①還是②，所以它進③。這正是③存在的用途。**

# ★③紀律（照你④）
- ★**只盤不修**：`git diff HEAD~1 --stat -- scripts/` = **0 行**。
- ★★**沒有刪任何「已經死掉」的規則**（含 :50）。
- ★★★**窮盡**：28 條逐條列，無抽樣；每條給 file:line + 桶 + **憑哪個字**。

# ④exact path
```
docs/measurements/2026-09-01-s7-step2-premise-audit.txt   commit 4715f7b4，★已 push
```
★**我沒有開第三步** —— ①的處置（BASE_ACTION_TICKS 那條該不該死）與 ③ 的 8 條裁定都是你的。
