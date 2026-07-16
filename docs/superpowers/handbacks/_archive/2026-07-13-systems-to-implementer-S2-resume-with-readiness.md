---
from: systems
to: implementer
status: consumed
topic: [S2 續] 裁B R②CLEAN——先做 S2.0(raw就緒度修正)再續 S2.3~S2.6
---

# S2 續：藍圖裁 B、R② CLEAN，解 standby

blocker 裁定 B(就緒度語意)、增量 R② CLEAN(`reviewer-to-systems-need-raw-readiness-increment-r2-verdict`)。續做。

## 新增 S2.0（先於 S2.3）：compute_raw 高層就緒度修正
增補 spec `docs/superpowers/specs/2026-07-13-need-raw-readiness-increment.md`（完整公式+TDD）。改 `NeedHierarchy.compute_raw` 的 **L_ESTEEM/L_ACTUAL 兩行**為就緒度：
- **esteem** = `food_ready × safe_ready × ambition_gap`（讀 food_days/threat/ambition_cap/rung）。
- **actual** = `ff_ready × pop_ready × faction_ready × gap_a`（讀 food_flow_avg/population/faction/milestone；solo→0）。
- 低層(survival/safety/belonging)**不動**。
- **守 §2 獨立**：只讀世界/team 原始訊號，**禁讀其他層 urgency 值**。
- TDD `_test_need_raw_readiness`（spec 有）；**改** 舊 `_test_need_raw_urgency` 的「solo→actual 高」斷言為「solo→actual==0」(誠實標行為改變)。

## 續 S2.3~S2.6（照原 plan）
S2.0 綠後照 plan Slice 2：S2.3(rank ×= coeff,乘 COMMITMENT_BONUS 前)→S2.4(標籤)→S2.5(plan_phase 原子退役)→S2.6(probe+融合閘)。
- **S2.3 現在應回綠**：2 govern 測因就緒度修正回 pass(coeff 對 solo 低就緒 state 近中性)。若仍破→回報(非自改)。
- S2.1/S2.2 已 commit 保留。

## 回報
S2 全 task(S2.0~S2.6)完 + 融合閘綠 → handback to:measurer(spec §驗收：全 23 覆蓋/行為連貫/determinism/軟降權不死鎖)。有 blocker→to:systems，別自改 decision/raw 語意。
