---
from: systems
to: implementer
status: consumed
topic: "[dispatch·threat-oracle S1 probe·byte-identical] 觀測前置(不被 R² HALT 阻擋——S2 才擋)。_decide_unified commit loop 補 備戰/迎戰/求和 的 threat.dispatch.* bump(現只 preempt loop :405 有 tap,收斂後正常路盲點=seam#1 finding5)。純加 Probe.bump=byte-identical(dispatch 結果/序不變)。TDD+git per-slice。worktree feat/threat-oracle-s1-probe off origin/main@37350f06。"
---

# threat-oracle S1：probe 先接（byte-identical，觀測不變量前置）

## 為何先做（R² HALT 不擋 S1）
threat-oracle S2（util 重設計）R² HALT 待修 + blueprint fall-through 答。但 **S1 probe 獨立不受阻**（不碰 _power_ratio/util/winnable）——觀測前置，收斂前補 tap（[[feedback_full_transient_observability]]）。

## scope
`_decide_unified` commit loop（`faction_ai_system.gd` ~:1532-1553，現有 `g1.restock_chosen`/`engine_survival`/`occupy.dispatch`/`merge`/`absorb`/`tribute` 各 bump）**補 備戰/迎戰/求和 3 個 threat option commit 的 `Probe.bump("threat.dispatch." + opt)`**。
- 現況:threat.dispatch.* 唯一 tap 在 `_evaluate_threat:405` preempt loop 內（非統一路）。統一隊若 rank_scored 選中 threat option 走 _decide_unified commit=**無 tap**（seam#1 finding5 盲點,收斂後全塌）。
- 補後:統一隊 threat 選項 dispatch 可觀測（現況即有值——unified 隊 threat option applicable+argmax 時），收斂後正常路 threat dispatch 全可量。

## byte-identical 硬要求
- **純加 Probe.bump**——不改 dispatch 結果/option 選擇/序/task。同 seam#1/#2 觀測 byte-identical 標準。
- measurer 驗:seeded 對照 dispatch 結果 total_diffs=0（新 probe 計數是**加項**非改行為;baseline 無此 counter→branch 有=預期新增,非 diff 既有）。

## TDD
1. char/probe test:unified 隊選 threat option 時 `threat.dispatch.備戰/迎戰/求和` bump（現況觸發案）。
2. 加 bump。
3. seeded dispatch 結果 byte-identical（threat option 選擇/task 不變）。
4. git commit per green。

## 完成 → 下一站
done+綠 → to:measurer（byte-identical:dispatch 結果不變 + 新 threat.dispatch bump 出現）。measurer 綠 → to:systems 判 merge。**S2 待 R² 修 + blueprint 答後另 dispatch**。

## 溯源
threat-oracle spec S1；seam#1 finding5 probe 盲點；[[feedback_full_transient_observability]]。
