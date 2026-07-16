---
from: systems
to: reviewer
status: consumed
topic: "[R²·v2 spec 設計審] 統一生產框架 v2——R① CLEAN 後寫。S1 製造precondition+tap/S2 survival-crush項+granary seam+常數分層(override留安全網)/S3 means-end統一發起(涵蓋faction_id=-1)/S4 移override+A3/A4 utility。兩行為層(urgency真fire/獨立隊has_facility成長)誠實標待measurer。異質v1已做不需重升(除非新大框)。CLEAN才dispatch implementer"
---

# R² merge-gate：統一生產框架 v2 spec 設計審

> **[worker 守則] 卡住/疑義 → handback `to:systems`，禁 `AskUserQuestion` 中斷用戶。**

R① re-verify CLEAN（你獨立重算 CRUSH 公式全 match、premise_contradiction 解）→ **systems 寫 v2 spec**。**R② 設計審 CLEAN 才 dispatch implementer。**

## spec
`docs/superpowers/specs/2026-07-16-unified-production-framework.md`（v2，rewrite；git 存 v1）

## 審什麼（真根治 vs 搬問題/退化/違 invariant）
1. **序（S2 override 留安全網 → S4 才拆）真無餓死窗口**？S2 驗收「餓隊 farming 主導」過了才 S4——這 gating 在 spec 明文，impl 能否落實（S2 未驗過 implementer 不准動 S4）？
2. **S2 survival-crush 融入 `_facility_score` 不破壞既有非-farming 設施評分**？（新項專屬 farming/食物設施，workshop/軍事等不掛此項——確認不誤加）。
3. **granary seam 修**（S2-2）：只改 facility-eval `food_days` reader、不動消耗/survival positional `effective_food`——切面乾淨、不誤傷定居隊消耗判定？
4. **S3 means-end 統一發起**：獨立隊自評估走**同 `_pick_facility` argmax**（非平行路）——設計是否真統一、不製造第二套決策系統（違「決策走引擎」原則）？
5. **常數分層**落地（`×0.8` flat/`×7` 人格化/`TARGET_PER_POP` 拆兩常數）——spec 明文夠不夠防 implementer 整串人格化？
6. **★誠實標記到位**？兩行為層斷言（urgency 真 fire、獨立隊 has_facility 成長）spec §狀態+§量測標「待 measurer」非篤定 emergent——這正是 R① 存在理由，確認沒又寫成空話。
7. **非回歸**：A2 precondition 不誤殺有設施隊、tap 禁耗 RNG、既有交易/飢荒/戰鬥不傷。

## 異質框外審
v1 spec 已升異質（Fable）框外審 + R① 異質手算——**v2 是 v1 訂正（同框架、修兩洞），不需重升異質**，除非你判 v2 引入**新**大框問題。你裁。

## 流向
CLEAN → to:systems → dispatch implementer（worktree TDD，S1→S2→**S2 驗收 gate**→S3→S4，整框架完成才 measurer full-HD：has_facility 成長含獨立隊/goods/surplus/deals/人格分化/urgency fire/no-op tap 趨零/無殘補釘/byte-identical）。
有結構洞/退化/違 invariant/搬家假拆 → to:systems halt。**dispatch-gate,設計最後一審。**
