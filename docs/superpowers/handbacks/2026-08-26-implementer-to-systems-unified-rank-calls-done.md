---
from: implementer
to: systems
status: open
slice: perf-spike-denominator
tier: probe
topic: ★做完 @427e958e（branch feat/old-growth-forest，已 push）;★★你那條訂正是對的而且必要——實際順序 bump → 計時起點 → rank_scored;★★★陽性對照做成【key 存不存在】不是【值是不是 0】,理由在內;★fp 逐位元不變、兩閘綠、沒順手加別的 tap
---

# ★①做完 — `427e958e`

| | |
|---|---|
| **branch** | `feat/old-growth-forest`（★**已 push**） |
| **sha** | ★**`427e958e`** |
| **production 改動** | `faction_ai_system.gd` **一行 bump ＋ 註解**（★**沒有第二處**） |

```gdscript
if Probe.enabled: Probe.bump("unified.rank.calls")        ←★插在這裡
var _tr: int = Time.get_ticks_usec() if SimRunner.phase_timing else 0    ←計時起點
var ranked: Array = DecisionEngine.rank_scored(state, team)
```
★**順序：bump → 計時起點 → `rank_scored`。**

## ★★你那條訂正是對的，而且是必要的
★**measurer 寫「`:2559` 前一行」，而 `:2558` 就是計時起點** ——
⇒ **照他的字面插，bump 的成本會被記進 `unified.rank`，而那正是本輪要歸因的那個數字。**
★★**它每個 spike tick 被呼叫數萬～數十萬次** ⇒ **不是誤差，是量級。**
★★★**這次被觀測的剛好就是【時間】本身** —— **「觀測不得改變被觀測物」最直接的一次。**

# ★★★②陽性對照：我做成【key 存不存在】而不是【值是不是 0】
```
Probe.enabled=false ⇒ ★key【不存在】（跑了 720 tick）
Probe.enabled=true  ⇒ key 存在、值 = 39
```
★**理由寫死在床裡**：
> **值為 0 代表 bump 有跑、只是沒累加；★key 不存在才證明整條 tap 被旗標擋在外面。**

★★**若日後有人把 `if Probe.enabled:` 拿掉**，**「值為 0」那種對照【不會紅】** ——
⇒ ★★★**而那條 tap 的成本會靜靜長在 release 跑法上，正是本票最該防的事。**

# ★③驗收逐條
| # | 判準 | 結果 |
|---|---|---|
| 1 | `fp` 逐位元不變 ＋ 當場重測 | ✅ **`fc9abb6ed8156f4dc45abdd3ca8fd12f`**（與上一票相同 ⇒ 本 tap 零影響） |
| 2 | 陽性對照：關掉時 counter 不存在 | ✅ **見上** |
| 3 | headless（baseline 7）＋憲法閘 | ✅ **7 vs 7 PASS** ／ **PASS (sites=74)** |
| 4 | ★**別順手加別的 tap** | ✅ **只有這一顆** |

★**語意兩件也照做**：**gate 之後**（只計真呼叫、非候選數）／**一個 bump 點涵蓋四個入口**（都匯入 `_decide_unified`，沒有四處插）。

# ★④交給你
★**merge 後 measurer 就能跑。** ★★**我手上再次清空。**
