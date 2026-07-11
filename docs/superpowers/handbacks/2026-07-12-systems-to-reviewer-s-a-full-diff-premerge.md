---
from: systems
to: reviewer
status: consumed
topic: [R② merge-gate diff 審] consolidation S-A 完整 diff(18 commits)——pivot 死碼/整合/gossip接口乾淨
---

# 對抗② merge-gate：consolidation S-A 完整 diff 審

merge 前最後一道（blueprint「merge 閘照常 reviewer diff R②」）。branch `feat/consolidation-s-a @78d45bd`，vs main（merge-base `8a2b579`，main 自 base 只 docs=零衝突）。18 commits，觸 scripts：options/terms/faction_ai/interaction/movement/npc_combat/message + team_data/decision_context。各 slice spec 已逐一 R² CLEAN——**本次審「組裝後的完整 diff」**（spec-level 審不到的整合面）。

## ★重點審（diff-level，非重審已 R² 的邏輯）
1. **pivot 死碼**（此 arc 多次翻案，怕殘留）：
   - order_target「漏接」誤修→撤（真根 combat 早退）：有無殘留 dead order_target 補接？
   - pursuit rev1 截斷/rev2 累積器 → rev3 絕對 straggler（棄前兩版）：`_pursuit_carry` 等前版死碼清乾淨？
   - C1 食壓 band → C2 survival-class（棄 band）：CONSOLIDATE_DAYS/band 死碼？
   - join/整併 → 統一「併入」（消冗餘）：舊 投靠+整併 兩 option 殘留？
   - §3b _find_absorber→_find_strong_neighbor axis：有無改錯 _find_absorber 的殘跡？
2. **整合面**：8 層 de-patch + 統一併入 + 吸納 + 完整 utility + magnet 組一起，有無 slice 間衝突/重複/失效（如 movement 三修 vs magnet finder）？
3. **gossip 接口乾淨**（ship 收尾）：`update_protector_rep` source 參 default 不改行為？message_system TODO seam 只註記無實作？
4. **地板守**：rank_scored 真 term 無 flat 湊 volume、gate#1 非搬餓在、不動征服平衡、cross-faction resolver 無暗閘。
5. **determinism**：磁鐵/utility 新 code 無新 randf（measurer 已驗零漂移+IDENTICAL，你複核 code 面）。

## 已綠（供你參照，非要你重跑）
- 融合閘：constitution PASS(sites=29)/import 零 script error（systems 剛跑）。
- measurer：零漂移 18/18 byte-identical + 三端/gate#1/determinism 綠（`s-a-zero-drift-CLEAN`）。
- magnet 大窗：196 完成/mega-blob 34.67 受控/annih=0。

## 完後
verdict to:systems。**CLEAN → systems merge**（決策統一 win + 完整 utility + magnet 一起入 main）。issues → 標明，systems 修/implementer 補再 merge。
