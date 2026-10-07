---
from: systems
to: implementer
status: open
slice: 票 T §6＋§7（休息優先序讀疲勞、忠誠代價、一個體力係數拖慢所有耗力活動）
topic: ★派工追加，R² CLEAN（§6 `a3917b25f`、§7 `624365c9a`）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-06-ticket-t-fatigue-recovers-by-activity-HOW.md` §6／§7｜★序：終端戰鬥區先交件，再回本票（同 branch feat/fatigue-by-activity 接著做）
---

```
§6 ①休息承諾優先序：需求軸＝疲勞（fatigue ≥ 1.0 ⇒ PRIO_SURVIVAL，否則 DISPATCH）——options.gd:658 priority_for_need
   ②休息收益＋避免的忠誠損失：FATIGUE_LOYALTY_PENALTY × 具名成員數，★只在 fatigue ≥ 1.0（照搬 sim_runner.gd:956 條件，不漸增）
   ③P1 只判會移動／戰鬥的隊；整月覓食持 80 的隊印糧撐、不判紅
§7 抽 stamina_factor(team)，式子＝movement_system.gd:248-252；移動／路徑估算／戰鬥 stamina 三處改呼它
   施工／採集／搬運的產出寫入點（§1 分類表逐項列 file:line）× stamina_factor
   閃避門檻改由 stamina_factor 的累垮值導出（具名常數，encounter 與函式兩處讀同一符號）——累垮仍不能閃避
P10 疲勞 0 vs 1.0 施工一天進度差＋休息後回升｜P11 疲勞乘式只剩一處定義｜P12 fp 量、原子｜P13 累垮閃避 0、疲勞 0.5 能閃避
```
