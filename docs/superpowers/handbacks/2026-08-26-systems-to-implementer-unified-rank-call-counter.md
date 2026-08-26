---
from: systems
to: implementer
status: consumed
slice: perf-spike-denominator
tier: probe
topic: ★一行 tap(measurer 提位置、我驗過並【修正一行】);★★★陷阱:他寫「:2559 前一行」,而 :2558 就是 phase_timing 的計時起點 ⇒ 放在 2558 與 2559 之間會把 bump 的成本記進 unified.rank 本身——而那正是我們要歸因的那個數字;★要求放在 :2558【之前】;★★背景=效能 arc 的定靶最後一顆
---

# ★①一行 tap
```gdscript
if Probe.enabled: Probe.bump("unified.rank.calls")
```

## ★★★而位置要比 measurer 寫的【再往上一行】—— 這是我驗出來的，不是他的錯
他寫「`faction_ai_system.gd:2559` 前一行」。★**我開檔看了現場**：
```gdscript
2558:  var _tr: int = Time.get_ticks_usec() if SimRunner.phase_timing else 0   ←★計時【起點】
2559:  var ranked: Array = DecisionEngine.rank_scored(state, team)
2561:  if SimRunner.phase_timing: _tr = _fai_pht("unified.rank", _tr)          ←★計時【終點】
```
⇒ ★★**放在 2558 與 2559 之間 ＝ bump 的成本被記進 `unified.rank` 這個 label 裡。**
★★★**而 `unified.rank` 正是我們這輪要歸因的那個數字，且它每個 spike tick 會被呼叫數萬～數十萬次。**
⇒ ★**要求：bump 放在 `:2558`【之前】**（`_should_reeval` gate 之後、計時起點之前）。

★**這條就是「觀測儀器不得改變被觀測物」的直接應用** —— **這次被觀測的剛好就是【時間】本身。**

# ★★②語意要對的兩件（measurer 已經想清楚，我覆核過，照做）
1. ★**放在 `_should_reeval` gate（`:2549` 那個 `return`）之後** ⇒ **只計【真的執行到這裡】的次數，被 cadence 節流擋掉的不算。**
   ★★**那正是我們要的「真呼叫次數」，不是「候選數」。**
2. ★**一個 bump 點涵蓋全部四個入口**（`assign.leader_unified :2489`／`member.unified :2511/2514`／`:437` threat force-reeval／`:3142` 獨立隊 solo）
   —— **因為它們最終都匯入 `_decide_unified` 同一個函式體。★不要四處插。**

# ★③為什麼要這顆（背景）
效能 arc 定靶到現在：
```
週期性、每小時一次、中位數 6.8 秒｜★不 ∝teams（101→202 沒放大）｜★不 ∝tiles（3.84× 不單調）
巢狀：loop1.factions ⊇ … ⊇ unified.rank ⊇ gather.*｜組成 early/mid/late 穩定
```
⇒ ★★**唯一還沒量的自變數是【每小時做了幾次決策】** —— **而 `unified.rank` 是 per-decision 的。**
★**measurer 已用讀 `WorldState` 算出 `Σ(1+members)` 的【上限】**（`tick0`：72+29=101 對上 teams），
★★**但那是上限**（`member_team_ids` 含子隊，而 `_assign_member_tasks:2501` 會 `continue` 跳過）
⇒ ★★★**所以需要真呼叫次數，而不是候選數。**

# ★④驗收
1. ★**`fp` 逐位元不變**（純觀測、`Probe.enabled` opt-in、不動控制流）—— ★★**並照紀律【當場重測基線寫進 handback】**
2. ★**陽性對照**：**`Probe.enabled` 關掉時該 counter 不存在**（證明是 opt-in 不是常駐成本）
3. headless（baseline 7）＋憲法閘 PASS
4. ★**別順手加別的 tap** —— **這輪只要這一個數字，多的會污染 `unified.rank` 的歸因。**

★**做完直接把 branch/sha 回我，我 merge 後 measurer 接著跑。**
