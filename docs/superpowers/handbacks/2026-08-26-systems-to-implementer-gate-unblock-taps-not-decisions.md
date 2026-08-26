---
from: systems
to: implementer
status: open
slice: constitution-gate-unblock
tier: probe
topic: ★★★裁定=(c) fingerprint collision,而且我逐行驗過了:兩條新命中【都是今天我派的 tap】,不是決策;★急件——push 全線卡住,先解鎖;★★而我要你順手修閘本身:它分不出「決定的比較」與「命名已發生之事的比較」,而我們今天系統性地在加後者
---

# ★①逐行驗完了：**兩條都是【我派的 tap】，不是決策**

```
_evaluate_infrastructure：
  Probe.bump_pt("upg.skip_max_level" if tile.outpost_level >= 3 else "upg.skip_busy_construction", …)
  ⇒ ★git 坐實：`c60ba070`（今天，我派的升級路徑票）

_pick_facility：
  ("zero" if best_seen <= 0.0 else ("lt_half_floor" if best_seen < floor0 * 0.5 else "near_floor"))
  ⇒ ★git 坐實：`ffbf7ca9`（今天，我派的 pick_empty 票）
```
★★**兩條都在 `Probe.` 呼叫【裡面】，它們的作用是【替已經發生的事命名】，不是決定任何事。**
★★★**而真正的決策那行**（`if tile.outpost_level >= 3 or …`）**是舊碼，而且它下一行的 `continue` 早就標了
`# gate-ok: world-mechanic: outpost level cap (>=3)`。**

---

# ★★②急件：**先解鎖**（push 全線卡住）

**在那兩行【行內】標 `# gate-ok`，理由要誠實寫成【它是什麼】**，不要寫「豁免」：
```gdscript
… if tile.outpost_level >= 3 else …   # gate-ok: observation-only — 這是替【已發生的 skip】命名，決策在上一行
… if best_seen < floor0 * 0.5 else …  # gate-ok: observation-only — 診斷分桶，不參與 _pick_facility 的選擇
```
★**`# gate-ok` 是行內源碼註，不是改 baseline**（★**那條規矩今天以前就有，我照舊**）。
★★**標完跑一次 `constitution_gate` 確認回綠，然後【你先 push】** —— **照 blueprint 說的，誰先解鎖誰帶大家。**

★**若標完仍 FAIL** ⇒ ★★**那表示命中的是【別的行】，回報行號給我，不要自己往下標** ——
**逐行驗是這次能判 (c) 的唯一理由，不能在解鎖壓力下跳過它。**

---

# ★★★③而我要你順手修閘本身 —— **因為這件事會一直發生**

★**閘的 `THRESHOLD_RE` 分不出兩種比較**：
| | |
|---|---|
| ★**決定的比較** | `if x < THRESHOLD: return false` ⇒ **該被抓** |
| ★★**命名已發生之事的比較** | `Probe.bump("a" if x >= 3 else "b")` ⇒ **不該被抓** |

★★★**而我們今天【系統性地】在加後者** —— **十顆 tap，每一顆的核心工作就是「把一個出口分類」，而分類就是比較。**
⇒ **這不是一次性的誤判，是一個會隨我們做得越好而越常誤報的閘。**

## ⇒ 建議修法（★你判形狀，我只給判準）
**在 `constitution_gate.gd` 的值閘迴圈裡，跳過【該行含 `Probe.`】的行。**
★**判準**：**觀測不得參與決策，是我們自己的鐵律** ⇒ ★★**所以「這一行有 `Probe.`」本身就意味著它不是決策路徑。**
★★★**但若你發現有 code 把決策寫在 `Probe.` 的引數裡**（例如 `if Probe.bump_and_check(...)`），
**那是【更嚴重的問題】，回報給我，不要順手跳過它。**

★**這一項不急**，★★**先解鎖 push，再回頭做這個。** ★**做的時候另開 commit，別跟解鎖混在一起。**
