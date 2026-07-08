---
from: measurer
to: qa
status: blocked_on_data
topic: A2b 量測完成，交付驗收判決（守衛A/B + target保真 + prio回歸）
---

# A2b 量測完成

**量測員獨立產數字，QA 讀數字判決。**

## 量測數字（.measure.json 詳見 worktree）

### HOB（seed=1337）
- **leader_bypass → 0** ✓（A2b 核心達成）
- subteam_bypass → 0 ✓
- 決策總計 15820，unified 佔 15765(99.7%)
- obey 率 92.7%；背離率 4.5%（unified src）
- **determinism PASS** ✓（逐事件相同）

### Constitution Gate
- PASS（current ⊆ baseline，無新增違憲 try_set）

### Game Sim Multi
- 4 配置全無崩（3340~21600 tick）
- leader 已走統一引擎派工

---

## QA 驗收待做（spec 03-14 項 → QA/系統 seeded 遊走）

**spec §驗收法 硬閘 2 項**（系統簽證必綠才交用戶）：

1. **守衛 A**（03 稀有性）：seeded 長跑 ≥數千 tick，leader **至少見數次主動征服攻擊**（count > 0）
   - A2b 前 baseline：leader 手 forced 強派攻擊(PRIO_FACTION)
   - A2b 後：leader 走引擎 competes(PRIO_DISPATCH 50)；威脅/生存可 preempt
   - 驗：征服**仍稀有但非零**（經濟意圖主；戰略稀有保）

2. **守衛 B**（03 遠距貢賦）：tribute-detachment 移除後，leader 無威脅時仍前往收遠距 member
   - A2b 前：遠距富 member → dispatch 子隊 TRIBUTE
   - A2b 後：leader 隊自行前往（engine 徵收 vs 駐守/survival 競秤）
   - 驗：dist > DISPATCH_DIST_THRESHOLD member **仍有貢賦流入**（treasury 增 > 0）

**spec §呈報藍圖 3 項**（02 要求 QA 遊走證據）：

3. **Issue 3a — target 保真**：seeded before/after 斷言
   - 攻擊 target = `_nearest_independent`（同現行手 cascade 1390）
   - 徵收 target = `_richest_member`（排自身）
   - 外交 target = `_nearest_independent`
   - 純路由不改 target（FA10 撤出範圍）

4. **Issue 3b — prio 降 + forced→competes regression**：seeded 遊走
   - leader 攻擊(PRIO_DISPATCH 50) **不** preempt 同隊 threat(70)/survival(80)
   - 無「攻擊裝上被高階丟」的 latch 徵候（A1 arbiter 語意保）
   - leader 該攻擊時仍攻擊（competes 但雙訊號加成使 util 通常勝）

5. **Issue 3c — edge-case：leader 離家徵收 capital 暴露**
   - leader 選 徵收/攻擊 離家期間，家 outpost 無持續無守暴露
   - threat 自然節制真觸：有威脅時 survival/駐守 壓過離家 option

---

## 量測員 side-note（非判決，僅觀察）

- HOB determinism PASS 已驗 code path 確定性（cadence 門無 RNG）
- arbiter_latch 率 4.3%（A1 baseline 報告見 A2a）；本次無惡化跡象
- leader unified 入站率 99.7% → A2b 路由接收達成

---

## 邏輯驗收前置阻擋（2026-07-09 增補）

QA 要求守衛A/B 的**精確計數**（leader 攻擊 count、遠距貢賦 $amount）。現有工具：
- HOB：只產決策 obey/背離 率，無 task 詳分
- seeded_warring_bed：long-run 框架，但 print 不含守衛 A/B 指標
- game_sim_multi：短配置，無長 run seeded

**缺口**：
1. leader 主動攻擊計數——需在 faction_ai 或 probe 層增 counter（print 或 ledger）
2. 遠距貢賦流入——需 dist-check + treasury delta 追蹤

**量測員邊界**：產數字、不改 code、不裁決。此二項需系統(HOW) session 定 seam + probe，非量測工具層能做。

**建議流向**：
- 系統 session：定義 probe spec（leader_attack_count、remote_tribute_sum）
- 實作 worktree：加 probe 邏輯
- 量測員：重跑 seeded → 產新指標 → QA 驗

## Handback 收件方式

目前 status: blocked_on_data（機械量測綠，邏輯前置缺工具）。QA/系統決策後，量測員重跑產數字。
