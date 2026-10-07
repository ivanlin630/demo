---
from: systems
to: reviewer
status: open
slice: 友善度 F7 收 R²：_check_distance 拆一支來源兩個出口
topic: 只看 F7 新增那段（spec「R² 打回（2026-10-07）」起、P7b 止）；F1–F6 你已 CLEAN
---

改法：新 `_distance_blockers` 回全部擋住的據點（{tile_pos, dist, rule}），`_check_distance` 改成它 is_empty()——掃描只留一份。
precheck_camp 逐筆問 `known_outpost_at`：有已知的 ⇒ 用已知裡最近一筆給名字距離；全未知 ⇒ 只說「離某個據點太近」。
★我自己加的一條請你打：不准「先挑最近一筆再問知不知道」（最近未知、次近已知時會丟掉玩家有權知道的原因）。
P7b：world-fp 不變＋bool 與 blockers.is_empty() 逐格一致。
