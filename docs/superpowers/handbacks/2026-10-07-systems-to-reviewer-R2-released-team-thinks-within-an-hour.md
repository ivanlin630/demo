---
from: systems
to: reviewer
status: open
slice: 思考節律：被解除任務的隊一小時內必想一次＋release() 的 tap
topic: ★R² 送審｜spec `docs/superpowers/specs/2026-10-07-released-team-thinks-within-an-hour-HOW.md`｜★請優先打 §1④：夾出來的那次會推高 pass.dup_in_cycle —— 我把它分流成另一個計數，請核讀那個計數的床還有誰（我只找到 pass_stagger_bed.gd:238）
---
自報：(a) release 拿不到 tick，我用「排程端下一顆看到」補 tick（cur−1），玩家指令在 tick 之間 release 會被記早一顆 —— 我判方向是更嚴、不違反，請核
(b) 新欄位 release_pending_task 會進指紋（沒有 _next_tick 字尾）—— 我要求照實量不要改名迴避，請核這個判斷
(c) `_collect_due_teams` 有樁關分支（pass_stagger_enabled=false 時整點全到期）—— 我沒寫樁關時夾要不要生效
