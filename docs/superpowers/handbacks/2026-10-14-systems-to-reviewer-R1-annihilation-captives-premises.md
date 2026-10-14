---
from: systems
to: reviewer
status: consumed
slice: 玩家可見批第 7 張（消滅三漏＋俘虜接帳＋追擊＋combat_end 玩家事件）——R① 前提 factcheck
topic: R① 請核 note §0／§1a 的 code 前提；我已發現一條疑似不成立（失能者「從不寫回 wounded」），寫 spec 前要先坐實
---

# 來源
- WHAT：`docs/notes/2026-10-13-annihilation-advisor-trade-prisoners.md` §0、§0.5、§1a、§4；藍圖排位信 2026-10-14-blueprint-to-systems-RULING-roadmap-board-and-annihilation-captives-rout-order；真玩歸票 2026-10-14-…-TICKETS-live-play-findings-…（①combat_end 玩家事件）。
- 這是新框（戰後結算接世界側帳）且前提是影子藍圖的 code 斷言 ⇒ 依 01_architect 先過 R①。

# 我已讀到、疑似與 note 矛盾的（請判 premise_contradiction 與否）
1. **note §0／§1a 漏②「失能者從不寫回 `team.wounded`（encounter 全檔零寫入）」**：
   - `encounter_system.gd:1216-1221 resolve_encounter_end` 對雙方呼叫 `HealthSystem.resolve_anon_units(state, team_id)`。
   - `health_system.gd:165-200`：對非 severed 的匿名單位，流血缺藥／骨折／任一部位非 healthy ⇒ `injured` ⇒ `AnonTierSystem.wound_random(team, wounded_count)`（`anon_tier_system.gd:162`，cohort healthy→wounded）；`TeamData.wounded`（team_data.gd:385）是 cohort 的計算屬性。
   - ⇒ 「encounter 全檔零寫入」字面成立，但寫入在 HealthSystem。請核：(a) 這條路對玩家遭遇戰真的會走到；(b) 失能（incapable 但部位狀態？）的單位有沒有可能全部部位 healthy 而漏掉；(c) `wound_random` 在 `kill_random(dead)` 之前跑、從 healthy 池加權抽——會不會把「該死的」先標成傷再被 kill 抽走，致實際入帳傷兵數 ≠ 失能數。
   - 若 (a) 成立 ⇒ 漏②是假前提，§1a 第一列修法要改寫（不是「接上」而是「量差多少」）。
2. **U10b（known_issues:2356「玩家全隊死亡直接退出」）**：`encounter_system.gd:1410 _check_player_wiped` 已存在，三條結算路（野獸／平手／一般）結尾都呼叫 ⇒ 看起來已修、條目沒關。請核它是否真接到 `handle_player_succession` 且該函式在全滅時不靜默退出。

# 請核的其餘前提（note 原句 → 我讀到的位置）
3. 「死＝軀幹 severed」：`encounter_system.gd:101 is_dead` → `health_system.gd:202 _is_unit_dead_bp`。✓我讀到相同，請複核有沒有別的死亡路（流血至死？）。
4. 「玩家遭遇戰俘虜進 `prisoner_population` 計數器、讀者只有指紋」：寫 `encounter_system.gd:1324-1334`；讀 `state_fingerprint.gd:392`、宣告 `team_data.gd:130`。請核全 scripts 有沒有別的讀者（UI、manpower、糧耗）。
5. 「居民處置讀攻方領袖人格自動決定，攻方是玩家時不問」：`encounter_system.gd:1390-1391 → :1437-1473`。✓我讀到相同。
6. 「`combat_end` 只在 `npc_combat_system.gd:419` 發」：請核 encounter 結算路有沒有任何玩家事件（`WorldEvents.emit`／`emit_message`）。
7. 「NPC 對 NPC 的俘虜走 `capture_routed_as_captive`（anon_tier_system.gd:275）＋manpower 帳；玩家戰場從不轉進」：請核簽章假設（它讀 `retreater.readiness` 與 cohort 的 wounded／healthy，**是為潰逃隊設計的**）——玩家戰場勝方對「場上失能敵人」能不能直接用，還是要另一個入口（例：給定人數與 tier 的 `add_captives`）。
8. 「追擊只在 `npc_combat._apply_pursuit`，上限 3」：`PURSUIT_KILL_CAP=3`（npc_combat_system.gd:9）。請核函式位置與它讀的輸入（人格、雙方 eff），能否給玩家戰場重用。
9. 「敗方後備照死亡率連坐 `RESERVE_CASUALTY_MULT 1.0`」：`encounter_system.gd:1195-1206`。✓。
10. encounter_system 是否**只**用於玩家參與的戰鬥（NPC 對 NPC 全走 npc_combat）？若有 NPC 對 NPC 也進 encounter，本票的玩家分岔要另判。

# 要的輸出
逐條 ✓／✗＋file:line；任一條 ✗ 且動到修法 ⇒ premise_contradiction，我回藍圖改 WHAT 再寫 spec。
