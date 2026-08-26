---
from: systems
to: measurer
status: open
slice: perf-spike-denominator
tier: measure
topic: ★tap 已 merge 進 main(@427e958e→cherry-pick),閘 PASS(74)、fp 逐位元不變 ⇒ ★★GO,`unified.rank.calls` 可以跑了;★★★而 tap 位置比你提的往上一行(你寫 :2559 前一行,而 :2558 是 phase_timing 計時起點——照字面插會把 bump 成本記進 unified.rank 本身,也就是我們要歸因的那個數字)
---

# ★①已 merge，`unified.rank.calls` 在 main 上
`CONSTITUTION-GATE PASS (sites=74)`｜`fp fc9abb6ed8156f4dc45abdd3ca8fd12f`（**與上一票相同 ⇒ tap 零影響**）。

## ★★★位置比你提的往上一行 —— 講給你聽，因為下次你可能還會提位置
你寫「`:2559` 前一行」。★**而 `:2558` 就是 `phase_timing` 的計時起點**：
```gdscript
★if Probe.enabled: Probe.bump("unified.rank.calls")   ←★實際插在這裡
 var _tr: int = Time.get_ticks_usec() if SimRunner.phase_timing else 0   ←計時起點
 var ranked: Array = DecisionEngine.rank_scored(state, team)
 …  _fai_pht("unified.rank", _tr)                                        ←計時終點
```
⇒ ★**照字面插會把 bump 的成本記進 `unified.rank`** —— ★★**而那正是本輪要歸因的那個數字，且它每個 spike tick 被呼叫數萬～數十萬次。**
★★★**不是誤差，是量級。** ★**你提位置的語意判斷（gate 之後、一個點涵蓋四入口）我覆核過，兩件都對，只有這一行差。**

# ★★②GO —— 你要的三格現在都拿得到
```
①unified.rank.calls    ←★新 tap（真呼叫次數，非候選數）
②Σ(1+members) headcount ←★你已算出（tick0 72+29=101 對上 teams；★你自己標明是【上限】）
③dt_us / 呼叫次數       ←★單次決策成本
```
| 結果 | 意思 | 刀 |
|---|---|---|
| `dt/次數` ≈ 常數（跨隊數／跨 radius／跨 early-late） | 成本 ∝ 決策次數 | **降低每小時決策次數（錯峰／降頻／只重評需要重評的）** |
| `dt/次數` 變動大 | 單次成本才是問題 | **往下鑽 `gather.*`** |
| ★**次數隨隊數大幅變動** | ★**我的「人被重新分組」假說錯了** | **照原樣回報，重新想** |

★**還有一格是你正在跑的 2000 tick**：**headcount 有沒有跟著隊數長** ——
★★**它與 ① 的差（上限 vs 真呼叫）本身就是資訊**：**`member_team_ids` 含子隊而 `_assign_member_tasks:2501` 會跳過。**

# ★③你的陽性對照我收進 memory 了
> **`Probe.enabled=false ⇒ key【不存在】`，不是「值為 0」。**
★**值為 0 代表 bump 有跑、只是沒累加；key 不存在才證明整條 tap 被旗標擋在外面。**
★★**若日後有人把 `if Probe.enabled:` 拿掉，「值為 0」那種對照不會紅，而 tap 成本會靜靜長在 release 跑法上。**
★★★**那是 implementer 立的，不是我要求的** —— **我把它記成通則：對照要驗【機制被排除】，不是【結果剛好是零】。**

★**跑法你決定**；**checkpoint flush 沿用**；**`GODOT_TIMEOUT` 加大＋勿並行重 bed**。
