---
from: blueprint
to: systems
status: consumed
topic: [GO] 用戶批投資做完整 consolidation utility(中等slice)——出spec建;守則:真term禁flat/征服真贏保留;測完才判世界抗拒
---

# 藍圖：用戶批准投資——建完整 consolidation utility

用戶裁（2026-07-11）：**投資做完整**（非先 ship 薄版）。理由：世界抗拒建在半成品上不誠實、中等 scope 可負擔、做完可能翻案、有機政體/S-B 全靠它。出完整 utility spec。

## 建什麼（照你盤點 §33-38 設計）
1. **投靠 ungate**：`options.gd:99` `food<3` OR **威脅驅（打不過的鄰→求保護，有餘裕也可觸）** → 真治謹慎/預防性投靠（非 C1 移窗）。
2. **absorb_drive 補全**：野心 + **仁慈(1-殘忍)/信義（保護傘型）** + **可期待收益**（target 產能/地 − pop 負擔）+ **擴展需求**（接 `ambition_gap` context:22）+ **資源餘裕**。
3. **新 context 欄**：`resource_slack`（自身餘裕）、`absorb_yield`（target 收益−負擔）。
4. **utility = 個性適配 × 資源可負擔 × 期待收益 × 擴展需求**（真戰略盤算，取代個性係數）。
5. 仁慈 wiring：`1-殘忍`/`信義`（非新 person value）。

## 守則（硬，別破）
- **禁 flat/硬優勢湊 volume**：補全＝讓決策更真實，**非把吸納調贏征服**。**征服若因真划算而贏＝合理 emergent，保留不動**。目標是「決策到位」非「consolidation 一定要多」。
- 新因子**全走 rank_scored 真 term**（統一框架內，非 bespoke），**過框架內冗餘 lens**（新 term 別跟既有重疊——如 resource_slack vs 既有 food_days 語意別撞）。
- 不重造概念（複用既有 ambition_gap/併入分流/loyalty init）。

## 驗收（measurer，補完後雙向重量）
- 雙向 completion（謹慎投靠 dispatch/complete、仁慈吸納 dispatch/complete）+ 跟征服的比。
- **判準（測完才成立）**：完整 utility 下——
  - consolidation 起量（謹慎投靠/仁慈吸納真發生、隊有聚合）→ **翻案，世界不抗拒,只是之前決策沒到位** → 我 signoff + 給 user 看新世界樣貌。
  - 仍 ~0（完整決策下強仍寧征服/弱仍覓食優先）→ **那才是真「世界抗拒」結論**（決策到位仍拒）→ 升 user a/b/c。
- gate#1 非搬餓 / 隊數不崩(防 mega-blob) / determinism / 三端不退化 仍守。

## 流程
- 顯著 utility 擴：**R②必過**（審完整 utility 設計健全 + 冗餘 lens）。前提全 file:line 坐實（盤點表），R① 免。
- spec→R②→implementer 疊 worktree→measurer 雙向重量→數字 to:blueprint。
- 決策統一 win 併在同 worktree，完整 utility 做完一起 merge（不先 ship 薄版）。

出 spec，繼續。這輪把 consolidation 從「薄選項」做成「真決策」。
