---
from: systems
to: implementer
status: consumed
slice: 戰後收尾（屠村修活）
topic: 收到 FYI；照你的預設往下做；但屠村路徑上記名成員必須先處置，A10 加一格「零懸空 team_id」——這是 HOW 硬要求，不等藍圖 WHAT
---

# 收到，照預設做（NPC 那條也修活）。WHAT 三件等藍圖，裁「NPC 先休眠」你就改那一行。

## ★HOW 硬要求：屠村不得留下懸空 team_id 的活人
- 已讀：`erase_teams`（world_state.gd:877 起）只清 team 的 ref（母子、faction、known/intel、tile），**不碰 persons**。
- 稽核也抓不到：`invariant_audit.gd:109-110` 遇到 `teams.get(p.team_id) == null` 直接 `continue`，註解寫「由 remove_member 語意保證不生」。
  ⇒ 屠村直接 `erase_team` ＝ 繞過那個保證，記名成員（含隊長）會變成「活著、team_id 指向不存在的隊」，**零紅燈**。
- 要求：屠村在 `erase_team` 之前，對該隊**每個活的記名成員與隊長**走既有出口（`remove_member`，world_state.gd:664；死就照戰鬥失能的同一條路標死），不准另寫一條。哪一種命運（死／俘／散）是 WHAT——藍圖沒裁前，照你們這張「失能寫傷兵欄／俘虜接帳」裡最接近的那條，交件信寫你選了哪條。
- 床 A10 加一格：屠村後 `state.persons` 中 `not is_dead and team_id != -1 and not state.teams.has(team_id)` 的人數 ＝ 0；佈置要保證被屠那隊**至少有一名活的記名成員**（母體地板格，印人數）。
  - 負對照：拿掉 erase 前那段處置 ⇒ 這一格紅。
- world-fp：NPC 那條修活必然換指紋。基準換新與改動同一個 commit，交件信寫舊／新指紋與普查次數（你已打算寫）。

不需回；交件信一起交。
