---
from: systems
to: measurer
status: open
topic: "[量測·全-HD 重跑] 絕境找糧真根修@2b9428c8——Team20+Team18+新死隊 specimen 給 QA 複判連貫窮死;A/B 生效驗"
---

# 量測：絕境找糧真根修 全-HD 重跑

真根修（A 買糧 look-before-leap + B 遷移找糧）實作完，systems 驗 6 約束全達成 + R②v2 CLEAN。branch `feat/desperation-food-seeking` @ **`2b9428c8`**（新分支，base 含 cherry-pick 的 tap/bed；worktree `.worktrees/desperation-food-seeking`，push）。base = main。

## 跑法（seed1337 force_full_hd reproducible，同前）
`reeval_attribution_bed.gd`，`SPECIMEN_TEAM_ID=? FORCE_FULL_HD=1 SPECIMEN_JSONL_OUT=...`（bed 已 seeded determinism，兩跑同 hash）。

## 要產（給 QA 複判連貫窮死）
1. **★Team20 同世界**：新 jsonl → 驗 A/B 生效——
   - **A**：買糧 candidates（trace）在「沒聽過食物賣單」時**不出現**（無純幻覺買糧）；聽過（含 stale）則出現＝合法。
   - **B**：Team20 **離開死市集移向視野內可達糧源**（trace 見 遷移找糧 winner+move+抵達承接覓食/買糧）；不再原地守買糧 880 tick。
2. **★Team18 同世界**：驗孤隊不再卡 31 天買糧 death-limbo（買不到→遷移或連貫死）。
3. **★新指定死隊 specimen**（bed 死亡偵測已修，可靠找真團滅隊）：死前 trace 求生選項輪番嘗試、四處落空才死＝連貫窮死。
4. **thrash 自然消**：買糧不選海市蜃樓→反覆重試源頭消→thrash-flip≈0（**不靠執行鎖**，執行鎖已廢）。
5. **不回歸**：determinism 兩跑同 hash；憲法 sites=29；established/attrition 全-HD 定性不惡化（平衡待 gen 重校，主判故事連貫）。

## 下游
- `.specimen.jsonl`（Team20/Team18/新死隊）→ **QA 故事判官複判**：連貫窮死否（「奮力找糧四處落空才死」非「守幻覺死」；**不要求嚴格階梯順序**，weight×人格 emergent）。
- headline handback `to:blueprint`（主判故事連貫，副報 A/B 數字）。全量一封信。

## 溯源
raw + measured_at_head `2b9428c8`。
