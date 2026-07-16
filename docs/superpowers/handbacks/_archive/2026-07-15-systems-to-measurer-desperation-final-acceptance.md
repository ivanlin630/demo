---
from: systems
to: measurer
status: consumed
topic: "[量測·最終 acceptance] desperation A+B+A-2 全@dfeecb80——全-HD重跑Team20+Team18+新死隊給QA複判連貫窮死;併入不再幻覺loop"
---

# 量測：desperation 最終 acceptance（A+B+A-2 全）

A 覆蓋完整：買糧✅（真出貨）+ 掠奪✅（移動延遲）+ **併入 A-2 v2（rejection-learning）**。systems 驗 6 約束+diff 全達成，R²全CLEAN。branch `feat/desperation-food-seeking` @ **`dfeecb80`**（含 A/B/A-2 v2；worktree `.worktrees/desperation-food-seeking`，push）。

## 跑法（seed1337 force_full_hd reproducible）
`reeval_attribution_bed.gd`，`SPECIMEN_TEAM_ID=? FORCE_FULL_HD=1 SPECIMEN_JSONL_OUT=...`（bed seeded，兩跑同 hash）。

## 要產（給 QA 最終複判連貫窮死）
1. **★Team20 + Team18 同世界**：新 jsonl 驗全部生效——
   - 買糧：無賣單時不入候選，有則入（A）。
   - 遷移找糧：困死市集移向視野內可達糧源（B）。
   - **併入：被拒後 cooldown 內不再纏同 host（A-2 v2）**——trace 見併入試一次→被拒→改選別路（非 42 次守同 host loop）。faction_id 若變=真併成；不變=被拒後改路（連貫，非 loop）。
2. **★新指定死隊 specimen**（bed 死亡偵測已修）：死前 trace 求生選項輪番嘗試、四處落空才死＝連貫窮死。
3. **thrash/loop 自然消**：買糧海市蜃樓 + 併入 reject-loop 源頭消 → 反覆重試源頭沒了（不靠執行鎖）。
4. **不回歸**：determinism 兩跑同 hash；憲法 sites=29；established/attrition 全-HD 定性不惡化（平衡待 gen 重校，主判故事連貫）。

## 下游
- `.specimen.jsonl`（Team20/Team18/新死隊）→ **QA 故事判官最終複判**：連貫窮死否（奮力找糧/遷移/試投靠被拒改路/四處落空才死，**非守任何幻覺 loop**；不要求嚴格階梯順序，weight×人格 emergent）。
- headline handback `to:blueprint`（主判故事連貫，副 A/B/A-2 數字）。全量一封信。

## 溯源
raw + measured_at_head `dfeecb80`。乞食死 rung=盲乞食 backlog（絕境階梯完整性 arc），非本輪驗（乞食本就從不被選，不影響本刀 A/B/A-2 連貫性）。
