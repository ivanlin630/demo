---
from: systems
to: implementer
status: open
topic: [工單 S2] 計畫層 phase導出+偏置term—讀S1穩定rung不碰rung;plan Task2(PHASE_GATHER已修併入);疊新worktree feat/plan-layer-s2
---

# 工單 S2：phase 導出 + 偏置 term（讀 rung 不碰 rung）

plan：`docs/superpowers/plans/2026-07-12-midlong-term-plan-layer.md` **Task 2**（R² CLEAN，PHASE_GATHER 已修「併入」）。S1 已 merged main（rung 事件穩定）。S2:從（缺口×個性×隊形）導出 `plan_phase` → `plan_phase_drive` term 進 rank_scored。**新 worktree `feat/plan-layer-s2` 疊當前 main（已 push，含 S1）。**

## 做（照 plan Task 2 Step 1-7）
- team_data 加 `plan_phase: String`;decision_context 加 PHASE_* const + `derive_plan_phase`（缺口×個性×隊形，見 plan Step 3）+ gather 填 `c.plan_phase`/`c.plan_phase_drive_map`。
- terms.gd 加 `plan_phase_drive` term;decision_engine weight 表 +`plan_phase_drive:1.0`;DecisionContext 加 `plan_phase_drive_map` 欄。
- 常數 PLAN_PHASE_DRIVE_MAG=0.4。
- TDD:`_test_plan_phase_derive`（缺糧→求糧/糧足人少→成長/子隊→NONE）+ `_test_plan_phase_bias`（求糧偏覓食不偏攻擊）。

## ★兩必守（R² 抓過）
1. **PHASE_GATHER option 用「併入」非「投靠」「整併」**（S-A consolidation 已統一「併入」,options.gd:49;舊名 rank_scored 靜默對不上）。求糧/成長 option 名 grep `DecisionOptions` 確認實名（覓食/買糧/貿易/返家補給/紮營/外交/併入）。
2. **冗餘 lens 自查**：`plan_phase_drive`（中長期 phase）vs `intent_fit`（短期意圖）vs `ambient_train_drive`——語意分層非雙算。**watch-item**:求糧 phase 偏「貿易」vs intent_fit 致富偏「貿易」窄邊緣可能疊加,MAG 0.4 已壓低——實作時留意,measurer 順帶觀察「貿易」util 量級。

## 守（Global Constraints）
- **讀 S1 rung 不碰 rung**（S2 不改 AmbitionLadder）。承諾綁 rung 事件（rung 穩→phase 穩，無獨立承諾狀態機）。
- determinism byte-identical（phase 導出純算術零 randf）。
- 統一框架:plan_phase_drive 只是偏置 term 輸入,rank_scored 仍唯一求解器。
- baseline 位移非 regression（phase 偏置改行為）。

## 驗收（handback to:measurer）
- phase 分布（不同個性/隊形 ≥2 種明顯 phase 序列模式，誠實非「全不同」）+ 偏置生效（求糧隊真偏覓食/貿易）+ 冗餘 lens 綠（貿易 util 無異常疊加）+ determinism + 融合閘 + headless 零新增。

## 註
- 序列:S2 merge 後 dispatch S3。別碰 S3/S4。
- 卡點 → to:systems（別問 user；如 S1 那樣 trace 抓到設計問題→呈報裁決）。
