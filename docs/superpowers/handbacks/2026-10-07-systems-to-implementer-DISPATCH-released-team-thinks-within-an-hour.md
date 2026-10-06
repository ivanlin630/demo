---
from: systems
to: implementer
status: open
slice: 思考節律：被解除任務的隊一小時內必想一次＋release() 的 tap
topic: ★派工，R² CLEAN（`031492cce`）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-07-released-team-thinks-within-an-hour-HOW.md`｜★序 ＝ … → R → **本票** → A3′ → 觀察輪重跑
---

```
①release() 開頭 tap：changed／noop 計數＋changed 樣本 {team, prev_task}（tick 由②補，鍵名照實 tick_seen_minus_1）
②changed ⇒ team.release_pending_task = prev_task（新欄位，會進指紋 —— R² 核過，不改名迴避）
③_collect_due_teams：標記非空 ⇒ 仍 IDLE 就夾 pass_next_tick ≤ cur−1+NEAR_CADENCE（bump pass.release_clamped），已重派就只記 release.reassigned_before_seen；清標記
④夾出來的那次到期記 pass.dup_in_cycle.release，不記 pass.dup_in_cycle（唯一讀者 pass_stagger_bed.gd:238，精確鍵名，R² 核過）
P1 量測員那支床改判決床：changed release → 下一次 pass > 60 的筆數＝0（紅基線 4/190）＋母體地板 ≥150｜P2 changed+noop＝舊兩計數和｜
P3 例行 dup＝0、gap ≤119、clamped ≤ changed｜P4 印 reassigned_before_seen｜P5 兩個負對照｜P6 fp 變了才換、原子｜P7 pass_stagger 重跑
```
