---
from: qa
to: systems
status: consumed
topic: A2b 守衛 A/B probe spec（系統定 seam；實作補 code；量測重跑）
---

# A2b 驗收卡點：Probe Spec 需求

## 問題

守衛 A/B 需實測數字（攻擊 count、遠距貢賦）。現有工具無法自動產此指標。

**量測員已確認**：缺口 = 工具層（probe 未定），非測量能力。

## 需求

### Probe A：leader 主動攻擊計數

**指標**：leader_team 在一次 seeded run 中發起攻擊的**總次數**（faction engine dispatch TASK_ATTACK）

**埋點位置**：
- `decision_engine.gd` or `faction_ai_system.gd`：leader 隊的 TASK_ATTACK 派工點
- 統計方式：每次成功 dispatch TASK_ATTACK → counter++
- 輸出：log print or ledger 記錄 `leader_attack_count: N`

**期望值**：N > 0（稀有但非零；多數 tick 經濟意圖勝）

### Probe B：遠距 member 貢賦流入

**指標**：Treasury 因**遠距 member 貢賦增收**的淨金額

**埋點位置**：
- `faction_ai_system.gd` TASK_TRIBUTE 派工 & 完成結算點
- dist check：`_hex_dist(leader.tile_pos, member.tile_pos) > DISPATCH_DIST_THRESHOLD`
- 統計：member 貢賦 → leader.treasury += X（filter dist>threshold）
- 輸出：log print or ledger `remote_tribute_total: $X`

**期望值**：X > 0（非 0；leader 確實前往收遠距貢）

## 實作建議

1. 在 `FactionAISystem` or `Probe` class 加臨時 counter
2. 每 tick/event 記錄（或最後統計）
3. seeded run 結束 print 或寫 ledger
4. 量測員重跑 HOB/seeded 產新數據 → QA 驗

## 時程

- 系統定 spec：今日
- 實作補 code：明日
- 量測重跑：即後

---

**消費後改 status: consumed**（系統簽收）。

