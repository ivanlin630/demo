---
from: systems
to: reviewer
status: consumed
topic: "[R²·持守統一 Slice 1 決策層 bonus-collapse·6912c6a7·★世界不凍過(teams 49→64 churn/attrition 1.13% vs baseline 1.80% 兩者皆活=latch反例回歸)+人格分化(固執0.3/務實0.06)+formula 5/5+gate74+determinism byte-identical·★implementer scope 裁:SOLO_COMMITMENT_BONUS=dead skip/survival_committed_stall=已stall_patience_factor人格化非flat→請裁納哪slice或排除] Slice 1 決策層 done。實際 3 live bonus 改讀(SOLO dead+survival_stall 已人格化)。審+裁 scope。"
branch: feat/persistence-slice1-bonus-collapse (6912c6a7)
---

# R²：持守統一 Slice 1（決策層 bonus-collapse）

## 做（spec §4/§5/§8-Slice1）
- 新 `team.persist_strength` 欄 + `PersistStrength` 公式 helper（人格加權沉沒成本、progressive-only、clamp 0.3<危機）。
- **3 live flat commitment bonus 改讀**：`COMMANDER_COMMITMENT_BONUS`/`FOUND_COMMITMENT_BONUS`/`COMMITMENT_BONUS`(decision_engine ×2)。

## ★implementer scope 誠實揭（請你裁）
- **SOLO_COMMITMENT_BONUS = dead 未用**（grep 無 live caller）→ implementer skip。**裁：dead code 不改對否**？
- **survival_committed_stall = 結構異**（stall 偵測機制，已 `stall_patience_factor` 人格化，非 flat util bonus）→ implementer 未 collapse。**裁：已人格化=已符持守設計(人格加權)→排除本 arc 對否，還是該統一到 persist_strength 概念（納哪 slice）**？我傾向排除（它非 flat 病、非 rank bonus，是不同機制的 stall 偵測、已人格化）。
- ∴ 原 spec「5 項」實際 = 3 live collapse + SOLO dead + survival_stall 已人格化 = **盤點 count 修正**（同 means-end R① 血證：count 別假設，implementer measure-first 揭真）。

## 驗
- **★世界不凍**（latch 反例回歸硬驗）：teams 49→64 成長/pop flux/attrition **1.13% vs baseline 1.80%（兩者皆活，非逐月不變）**。specimen-off。
- 人格分化（固執 0.3/務實 0.06）。formula 5/5 + headless 0-new + gate 74 + determinism byte-identical(052c0924)。不碰執行層（Slice 3）。

## ★reviewer focus（refute + 裁）
1. persist_strength 公式落地對否（人格加權 sunk、progressive-only、clamp<危機）？
2. 3 bonus 改讀對否（決策層 rank 偏置，既有 hysteresis 行為不退化）？
3. **★scope 裁**：SOLO dead skip 對否？survival_committed_stall 已人格化排除本 arc 對否（vs 納某 slice）？
4. **★世界不凍真否**（teams churn/attrition 兩者皆活=latch 反例回歸真過，別又凍）？
5. 人格分化（固執黏/務實轉）合理否？

**CLEAN → merge Slice 1 → Slice 2（執行層寫回+新鮮度）。** 有洞 → 回 `to:systems`。
