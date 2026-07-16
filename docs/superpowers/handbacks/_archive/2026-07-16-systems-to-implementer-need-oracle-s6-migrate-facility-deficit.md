---
from: systems
to: implementer
status: consumed
topic: "[DISPATCH·S6 遷facility_deficit·完①] blueprint裁甲:_facility_deficit non-food(workshop/apothecary/weaponsmith/armorsmith/smeltery/mint/stable)引擎外走TARGET_PER_POP各算=單一源違規→遷oracle need。★注意:goods need_keep=0(純貿易)→workshop-for-goods deficit由demand驅非keep;保facility-specific gating(weaponsmith threat/mint ore/stable mounts)只遷QUANTITY-target算。farming已遷(granary)勿動。終端消耗品oracle內flat=blueprint裁可接受deferred勿改。Tier1+完成handback [DONE]→measurer乾淨全量。禁AskUserQuestion"
---

# [DISPATCH] S6 遷 `_facility_deficit` → oracle（完 ①，真單一源）

> **[worker 守則] 卡住/疑義 → handback `to:systems`，禁 `AskUserQuestion`。**

## 授權
blueprint 裁甲（乾淨證據 ① 靜態查抓到 `_facility_deficit` non-food 殘各算）：**S6 遷完 ① 才 clean → measurer 乾淨全量 → 批**。

## 工作區
worktree `.worktrees/need-oracle`，branch `feat/need-oracle`（S1-S5 @ arc-done head，續 S6）。spec v2 唯一真相。

## S6：遷 `_facility_deficit` non-food readers → NeedOracle need
`faction_ai_system.gd _facility_deficit`：除 farming（已遷 granary seam，**勿動**）外，non-food 設施 deficit 各算 QUANTITY-target 走 `TARGET_PER_POP × pop` / `pop × const`（`:3079` workshop goods/tools/arrows、apothecary medicine、weaponsmith/armorsmith/smeltery/mint/stable…）→ **改讀 `NeedOracle` need**（消殘各算，與生產/商業共讀同源）。

### ★關鍵設計（別踩坑）
1. **goods need_keep=0（純貿易品）**：workshop-for-goods 的 deficit **由 `demand` 驅動非 need_keep**（想產 goods 賣=demand 大→該建工坊）。用**適當 need 組合**：deficit 反映「該資源總 need（need_keep + demand 視資源性質）vs 現產能/持有」。tools/arrows/武器=need_keep（自用）為主;goods=demand。
2. **保 facility-specific gating**：weaponsmith/armorsmith 的 `_threat_recent` gate、mint 的 ore-tile 條件、stable 的 mounts、smeltery 的「武器坊存在」——**這些 applicability/facility-physics 邏輯保留**，只遷「該資源需多少量」的 QUANTITY-target 計算到 oracle。
3. **終端消耗品 oracle 內 self-use flat（`need_oracle:35`）= blueprint 裁可接受 deferred，勿改**（戰耗/造耗/傷耗率未定義，值待建了機制再推導，已記 known-deferred）。

## 非回歸（★遷 facility_deficit 動到生產框架 facility-choice）
- **生產框架 facility-build 不破**：facility 選擇（`_pick_facility`/`_facility_score`）現讀遷後 deficit——facility 仍該建、人格分化在（S4 crossover 已驗，S6 後重驗 facility 建造行為）。
- **holding 側保留 seam-aware**（別碰 effective_holding）。守恆/食安/觀測 byte-identical。

## 完成 → 交回
S6 done + Tier1（facility deficit 遷後 facility 仍建、無各算殘留 grep 淨）→ handback topic 含 **`[DONE]`** `to:systems`（Tier1 + grep 確認 `_facility_deficit` 無殘 TARGET_PER_POP directs + head）→ systems 派 measurer **乾淨全量**①②③④（①need 真單一源無殘/②餘量一致 goods 死鎖解量化/③停產+溢出守恆數字/④無回歸）→ blueprint 批 → merge Arc1 → Arc2。
