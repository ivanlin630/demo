---
from: systems
to: implementer
status: open
topic: "[裁定 Option 1] reeval_bed 加 seed(seed_val)——determinism 是量測床正確性;第三種死法已結案無依賴;L3 補+快驗→measurer 跑"
---

# 裁定：Option 1（加 `seed(seed_val)`）

先肯定：你 dispatch 要你驗 determinism → 你驗了、發現 bed 本就非確定、且**沒擅自加 seed**（會動 blueprint 調查依賴）→ flag 給我裁。**這正是對的**（連動風險 flag 不擅改，同前 provenance 紀律）。記一功。

## 裁定
**Option 1：`reeval_attribution_bed.gd` 加 `seed(seed_val)`**（1 行，`GameSetup.setup` 前，鏡射 `WarringHarness.run:91`）。

## 理由（你的顧慮已查證解除）
1. **「第三種死法」已結案**：session 起始 commit `3154d52e 查證結案=假象`——結論「decision_count=0 是 SpecimenTracer tap-gap 非真死」**正是本 arc 觀測 slice Fix B 修的東西**（`_decide_subteam` 沒接 tap）。調查完結，**無 live 依賴** bed 的非-seeded 輸出。
2. **reeval_bed 引用都是歷史 measure.json/handback 記錄**（不可變 artifact），非對特定非-seeded 世界的 live 依賴。
3. **determinism 是量測床的正確性要求**：acceptance 要 reproducible specimen trace + branch-vs-base headline 才能把 thrash delta 歸因給 fix（非-seeded=每跑不同世界=delta 是噪音）。**非-seeded 是潛在缺陷**（連 memory `reference_multi_sanity_unseeded`），該修非繞。

## 請做（L3）
1. `reeval_attribution_bed.gd`：`GameSetup.setup(state, config)` 前加 `seed(seed_val)`（全域 runtime RNG 播種）。
2. 更頂部註解：「第三種死法」那段標「已結案（3154d52e），bed 現 seed 全域 RNG＝確定性」（免下個讀者誤以為仍依賴非-seeded 世界）。
3. 快驗：`SPECIMEN_TEAM_ID=7 FORCE_FULL_HD=1 SPECIMEN_JSONL_OUT=<path>` **兩跑 jsonl hash 相同**（determinism 達成）；bed 原有 attribution 輸出仍正常（無 SCRIPT ERROR；世界變了但 bed 無硬斷特定隊命運）。
4. commit execlock 分支 + push + handback `to:systems`（回報兩跑同 hash）。

## 之後
→ measurer 用此 bed 跑 execlock 全-HD acceptance（seed1337 reproducible：headline churn/attrition branch vs base + `.specimen.jsonl`）→ QA 故事判 → blueprint 批 execlock。
