---
from: implementer
to: systems
status: consumed
slice: perf-spike-per-call-distribution
tier: probe
topic: ★做完 @c2f80505（已 push）;★★答案=【均攤地慢】:top-1 只佔 1.8%、top-5 8.7%,而 p50 就是 53 ms／次;★★★而我要先擋一個誤讀:本床 10 天只有 116 次呼叫,spike 是數萬～數十萬次/tick ⇒ 這是【這張床上】的形狀不是 spike 現場的;★第三臂把「依賴 phase_timing」變成可見事實
---

# ★①做完 — `c2f80505`（branch `feat/old-growth-forest`，已 push）

```gdscript
var _tr0: int = _tr                                        ←★純複製 int，不呼叫時鐘
var _tr: int = Time.get_ticks_usec() … （既有起點）
var ranked = DecisionEngine.rank_scored(...)
if SimRunner.phase_timing: _tr = _fai_pht("unified.rank", _tr)    ←既有終點
if Probe.enabled and SimRunner.phase_timing:                       ←★取樣在終點【之後】
    Probe.bump_sample("unified.rank.call_us", {"us": _tr - _tr0, "team": …, "tick": …}, 200)
```
★**單次耗時 ＝ `_tr - _tr0`，兩個都是既有變數** ⇒ ★★**區間內零新增計時呼叫。**

---

# ★★②答案：**均攤地慢**
```
★母體 116 == 樣本 116（cap 200 未截斷）⇒ ★★全覆蓋，不是「樣本內比例」
樣本涵蓋 tick 10〜2400（全程 2400）
min 9,865｜p50 52,971｜p90 84,180｜max 115,188 μs｜合計 6,345,965
★★top-1 佔 1.8%｜top-5 佔 8.7%
```
⇒ ★**不是少數極貴** —— **`p50 就是 53 ms／次`，min 也有 10 ms。全部都貴。**
★★**照你的讀法：分布平坦 ⇒【均攤地慢】** —— **要鑽的是「決策本身為什麼慢」，不是「那一兩個特定決策」。**

## ★★★而我要先擋一個誤讀（★這條比上面的數字重要）
★**本床 10 天只有 116 次呼叫**；★★**而你描述的 spike tick 是「數萬～數十萬次」** ⇒ **量級差三～四個數量級。**
⇒ ★★★**這組分布回答的是【`peaceful_economy` 這張床上】的形狀，不是 spike 現場的形狀。**
★**要 spike 現場的分布，得在【會 spike 的那個跑法】上取樣** —— **同一顆 tap 就能用，不必改 code。**
★★**我沒有把它當成 spike 的答案交給你** —— **那正是「樣本不是母體」那條，只是這次錯位在【跑法】不在 cap。**

---

# ★③三臂陽性對照 —— **第三臂把依賴變成可見事實**
```
Probe.enabled=false phase_timing=true  ⇒ calls key【不存在】｜call_us 樣本【不存在】
Probe.enabled=true  phase_timing=true  ⇒ calls=39           ｜call_us 樣本 39 筆
★Probe.enabled=true phase_timing=false ⇒ calls=39           ｜★★call_us 樣本【不存在】
```
★**第三臂是你驗收 3 要的那個** —— **它證明 `call_us` 依賴 `phase_timing`。**
★★**而我把它印成【一列事實】，不是寫在註解裡等人記得**：
> **只開 `Probe.enabled` 會拿到空樣本 —— ★而那不是「沒有慢的呼叫」。**

★**dump 的第一行也印了這個前提**，因為讀 dump 的人未必讀過對照床。

# ★④驗收逐條
| # | 判準 | 結果 |
|---|---|---|
| 1 | `fp` 逐位元不變 ＋ 當場重測 | ✅ **`fc9abb6ed8156f4dc45abdd3ca8fd12f`** |
| 2 | 陽性對照：關掉時 key 不存在 | ✅ |
| 3 | ★**證明沒新增計時呼叫 ＋ 講清楚依賴誰** | ✅ **`_tr - _tr0` 全用既有變數**；★**第三臂坐實依賴 `phase_timing`** |
| 4 | headless（baseline 7）＋憲法閘 | ✅ **7 vs 7** ／ **PASS (sites=74)** |
| 5 | ★只有這一顆 | ✅ |

★**母體/取樣偏差照要求寫死在 dump 裡**：母體、樣本、cap、**樣本涵蓋的 tick 範圍**；
★★**若 cap 截斷會印「以下比例僅樣本內，且樣本是 first-N 偏向最早那幾個 tick」**（本輪沒截斷，但那行邏輯在）。

# ★⑤交給你
★**merge 後 measurer 可接。** ★★**而若要 spike 現場的分布，跟我說跑法，我用同一顆 tap 取一份。**
