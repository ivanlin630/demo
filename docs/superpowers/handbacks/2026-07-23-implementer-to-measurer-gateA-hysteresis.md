---
from: implementer
to: measurer
status: consumed
topic: GATE-A 二刀 返家閉環 hysteresis — measure（破 oscillation，committed-not-executed）
branch: feat/gateA-return-hysteresis
commit: 8c7fbd83
spec: docs/superpowers/specs/2026-07-23-gateA-2nd-cut-return-hysteresis.md
---

# GATE-A 二刀 返家閉環 hysteresis — 做完，量測請收

## 改動（2 touch）
根：返家補給 applicable `food_days<DESPERATION(3)` → 隊返家途中 food 過 3 → option 消失 → 漂回
idle/trade → 震盪（days_left 卡 1.6-3.0 never 爬升=never 到家補飽）= **committed-not-executed**（手不聽腦家族）。

- **① ★touch0**（reviewer 必補）：`decision_context` gather `c.current_task = team.current_task`（team 自身欄 team_data:98 = 自身狀態非 god-view）。
- **② `options 返家補給` applicable +hysteresis**：`or (ctx.current_task == TeamData.TASK_RETURN_HOME and ctx.food_days < DecisionTerms.RETURN_HYSTERESIS_DAYS)`；新 const `terms.RETURN_HYSTERESIS_DAYS=5.0`（=RESTOCK_DAYS 重用非新魔數）→ **band[3,5]**：trigger 3 開始返家、途中撐到 food≥5 停 → 完成返家+到家 harvest 補到 5+ 才出門。

## 自驗（皆綠）
- TDD `gateA_hysteresis_test` **5/5**（①returning+food 3-5→applicable true[原 false] ②非 returning 不變 ③food≥5 釋放 ④food<3 trigger 不變 ⑤productive returning restock 1.0）。RED：hysteresis clause neuter → ① FAIL。
- headless 0-new（3 baseline）。gate PASS sites=75（無新閘）。
- determinism seed1337×2mo×2 跑 byte-identical MD5 `25655ec0`（純算術無 RNG）。

## 量測請抓（spec §驗收，餵 QA 判故事）
1. **返家補給 chosen**（2638→? 應降=不再狂震盪）。
2. **★GATE-A bucket %**（58-73%→?）。
3. **days_left 卡點**（1.6-3.0）是否爬升。
4. **★returning 隊「到家+harvest+food 爬過 5+出門」閉環逐 tick 坐實**（reviewer 要求：非只信邏輯自洽，逐 tick trace returning 隊真到家、harvest、food 過 5、才出門）。
5. **forest 不誤鎖 + ★不過鎖**（food≥5 釋放→正常出門率，別鎖死該出門的隊）。
6. **end-絕境**（15/26→?）。
7. 無新餓死。
8. §④b sample + specimen → QA。

床：`godot --path .worktrees/gateA-hysteresis` 對 branch 8c7fbd83 跑（★禁原地 checkout）。
base=GATE-A merge 後 main 6d9c90c5（含 GATE-A 一刀）。

## 完成判定 = systems + reviewer（merge-gate R²）。做完 → to:QA 判故事：
returning 隊撐到真到家補飽脫 oscillation coherent；forest/正常隊不過鎖（food≥5 釋放正常出門）。
GATE-B（死法②撮合）+ settled 薄利（carrying-capacity valves）= 後續。
