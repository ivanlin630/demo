---
from: implementer
to: systems
status: consumed
topic: "[DONE·完①] need oracle S6 遷 _facility_deficit non-food→oracle(a8466b9e):真單一源,grep 淨。facility 仍建(確定性檢 _pick_facility→workshop deficit 1.00)+determinism byte-identical+CoinAudit=0+headless 3+3。Arc1 code 全完→measurer 乾淨全量"
---
# [DONE] Arc1 完 ① — S6 遷 `_facility_deficit` → oracle（真單一源）

branch `feat/need-oracle` @ `a8466b9e`（已 push，7 commit）。Arc1 S1-S6 code 全完。

## S6 交付
`_facility_deficit` non-food QUANTITY-target 遷 NeedOracle need（消引擎外各算 TARGET_PER_POP 殘留，與生產/商業共讀同源）：
- **workshop**：goods=demand 驅（need_keep=0 純貿易）、tools/arrows=need_keep（自用）。target=兩量和（res 性質自動選）、tgt<=0 skip（goods 無買家不逼建工坊）。
- **apothecary** medicine / **armorsmith** armor(兩級和) / **smeltery** ore_steel(供應鏈) / **stable** mounts → need_keep。
- **★保 facility gating**：weaponsmith(armed_ratio 非 quantity-target)/mint(ore-tile physics)=保留；armorsmith/smeltery threat/facility-existence gate=保留。farming(granary)勿動。
- 終端消耗品 oracle 內 self_use flat = blueprint 裁 known-deferred，勿改。

## 驗（grep 淨 + 非退化）
- **★grep 淨**：`_facility_deficit` body 無殘 `TARGET_PER_POP各算`/`pop×const` quantity-target（只 farming granary + weaponsmith armed_ratio/mint ore = 非 quantity）。
- **★facility 仍建（確定性檢，非 unseeded）**：構食足缺 tools 隊 → `workshop_deficit=1.00`、`_pick_facility→workshop`。**facility-build 非退化根確認**（生產框架 facility-choice 讀遷後 deficit 仍正常）。
- **Tier1 19 綠**（workshop tools/arrows 驅 + goods demand 驅非 keep + apothecary medicine 驅）。
- **CoinAudit delta=0×4** + **determinism byte-identical MD5 F85E975A** + **headless 3+3 baseline 0 net new**。
- ⚠ 註：`game_sim_multi` 單跑 Manufacture=0＝**unseeded drift**（該 bed 無 seed，見 [[reference_multi_sanity_unseeded]]）；facility-build 機制經確定性檢證正常，真 production revive = measurer full-HD 真閘。

## ★Arc1 全貌（S1-S6，7 commit）
| slice | 內容 |
|---|---|
| S1-S3 | NeedOracle 三分量（food 自用 / 供應鏈 gap+gating+多配方 / 貿易 demand 非幽靈+野心） |
| S4a | manufacturing reader 切 oracle + per-recipe 停產 |
| S4b | commerce reserve→need_keep（goods 死鎖解） |
| S5 | 溢出落地雙 sink 守恆 + TARGET_PER_POP 退役 |
| **S6** | **_facility_deficit non-food 遷 oracle（真單一源，完①）** |

**核心達成**：need 側**真單一源**（生產/商業/facility-choice 共讀 NeedOracle，無各算殘留）、R² 兩量方向修（死鎖解）、TARGET decision 身分全退（pricing physics 保留）、holding 側 seam-aware 保留、NeedHierarchy 零改動。

## measurer 乾淨全量待驗（①②③④，arc 真閘）
①need 真單一源無殘 / ②餘量一致 goods 死鎖解量化 / ③停產+溢出守恆數字 / ④無回歸（食安/生產框架 facility-choice/holding-seam）。誠實標：真 revive + 行為正確性 = full-HD 坐實。

## 溯源
spec v2 / R① CLEAN / R② round2 CLEAN / boundary-clarified / S6 dispatch（blueprint 裁甲）。git 保 S1-S6。
