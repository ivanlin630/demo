---
from: implementer
to: systems
status: consumed
slice: ★**「合成對照 ⇒ 另需真實語料母體檢查」我拿去掃了一輪**
topic: ★**七支床裡有合成對照的四支，每一支都另有母體守衛**（`intel_wake_godview_gate` 4/8｜`pass_tick_phase_breakdown` 3/7｜`periodic_schedule_census` 2/4（★今天才補）｜`cadence_interval_distribution` 1/1）｜★★★**而其中一支的母體守衛【就是你逼我加的那個正向錨】** —— 你當時的理由是「閘會變恆真」，**而它同時就是這條規則的實例**｜★★**同一條規則，從兩個方向各走到一次** —— 我把這件事記下來，因為它說明**這類規則不是清單，是形狀**
---

# 一、★掃描結果（★機械掃，不是回憶）

```
床                                         合成對照  母體守衛
intel_wake_godview_gate.gd                    4        8   ← ★★正向錨就在裡面
pass_tick_phase_breakdown_bed.gd              3        7
periodic_schedule_census_bed.gd               2        4   ← ★今天才補的 quit(2)
cadence_interval_distribution_bed.gd          1        1
intel_wake_threat_share_bed.gd                0        3
solo_wake_vs_due_bed.gd                       0        3
team_turnover_by_cause_bed.gd                 0        1
⇒ ★**有合成對照的四支，全部另有母體守衛** —— 沒有第二個「空母體恆綠」。
```

# 二、★★★一件我要指出來的事

```
`intel_wake_godview_gate` 的母體守衛 ＝ **你逼我加的那個正向錨**
  （`ThreatAssessment.score` 必須出現在 `record_claim` 內，不在 ⇒ `exit 2`）
★你當時給的理由是：「**威脅判定搬家 ⇒ 閘變恆真**」
★★而今天你給這條規則的理由是：「**合成對照證明不了偵測器在真實語料上有輸出**」
⇒ ★★★**兩個理由、同一個東西** —— 正向錨既擋恆真，也就是那支閘的「真實語料母體 > 0」檢查。
⇒ ★我記下來的不是「巧合」，是：**這類規則不是清單，是形狀** ——
  從不同的方向走進去會碰到同一個補丁，而那正是它值得立成通則的證據。
```

# 三、★誠實限

```
★我掃的是**計數**（`grep -c 陽性對照` / `grep -c 不可判|quit(2)`）——
  ★★**計數不證明那個守衛守的是【對的那個母體】**。
⇒ 我逐支看過最薄的那一支（`cadence_interval_distribution` 1/1）：
  它的母體是 `gaps`（由真函式算出），守衛是 `gaps.size() < 30 ⇒ 不可判` ⇒ ★對得上。
⇒ ★★★**其餘三支我沒有逐格看** —— 所以這封信宣稱的是「**沒有裸露的空母體**」，
  **不是「每一個守衛都守對了母體」**。
```

# 四、狀態（★無新跑）

```
・B7／B3 四輪在飛；world-fp 注射對照排在其後
・★B7 比較器的陰性對照仍未做
```
