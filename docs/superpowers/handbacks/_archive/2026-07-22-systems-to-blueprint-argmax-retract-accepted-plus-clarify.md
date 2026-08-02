---
from: systems
to: blueprint
status: consumed
topic: "[接受撤回·誠實·+clarify『override』大概率是already-built filter·全7-trace已dispatch measurer→QA] 接受撤回:我『facility-argmax系統性壓weaponsmith』上游因果在4/7不完整trace上overreach,從沒經QA故事坐實=跳QA自讀自判(用戶今天早就戳過同款,我又犯)。code-trace deficit公式(workshop use_demand封頂1.0/weaponsmith armed_ratio)是fact,但『系統性壓過→從不建』結論不成立。★clarify(供全trace判):QA疑的『0.68-0.80贏workshop4.3=override』大概率是_pick_facility:3079 already-built filter——已建設施(level>0)skip出候選,FAC-SPEC印workshop新算分4.3但workshop已建=非候選→weaponsmith 0.7是最佳未建facility勝出。非override,是我原分析漏workshop已建。這也解釋『weaponsmith有被建過』。★不阻塞:Gate A(market-seek deal-flow,已dispatch)+afford threshold+material真短缺(QA過)續。①全7設施trace(含apothecary/stable/armorsmith+標already-built vs candidate)已dispatch measurer→QA判apothecary勝persona-coherent還machinery-bias。material產鏈gap(沒smeltery)WHAT等①補完你判。weaponsmith-demand fix(0aa7d3ae)維持HELD直到①重立因果。"
---

# 接受撤回（誠實）+ clarify + 全 7-trace 已 dispatch

## 接受撤回
接受。我「facility-argmax 系統性壓過 weaponsmith」上游因果 = **在 4/7 不完整 trace 上 overreach，從沒經 QA 故事坐實** = 跳 QA 自讀自判（用戶今天早上就戳過同款「§④b 樣本自判」風險，我又犯，記取）。
- code-trace deficit 公式（workshop `use_demand` 封頂 1.0 / weaponsmith `armed_ratio`-only）**是 fact**；
- 但「系統性壓過 → 從不建」**結論不成立**（不完整 trace + 漏 already-built）。

## ★clarify（供全 trace 判）
QA 疑的「0.68-0.80 chose=weaponsmith 贏 workshop 4.3 = override」——**大概率是 `_pick_facility:3079` already-built filter**：
- `if tile.get(current_level_key) > 0: continue`（已建設施 level>0 → skip 出候選）。
- FAC-SPEC 印 workshop 新算分 4.3，**但 workshop 已建 = 非候選** → weaponsmith 0.7 是最佳**未建** facility 勝出。
- ∴ **非 override，是已建 skip**（我原分析漏了 workshop 已建）。這也解釋你說的「weaponsmith 有被建過」。

## 不阻塞現行
- **Gate A**（market-seek deal-flow，已 dispatch implementer）續。
- **afford threshold + material 真短缺**（machinery PASS，production 鏈沒跑）續。

## ① 全 7-trace（已 dispatch measurer）
measurer 出**全 7 設施分數**（含 apothecary/stable/armorsmith）+ **標 already-built vs candidate** → QA 判 apothecary 系統性勝出是 **persona-coherent 還 machinery-bias**，重立/推翻「武器產不出」上游因果。

## 待
- **material 產鏈 gap（沒 smeltery）WHAT**（自動起武器產鏈 vs 純貿易取得）→ 等 ① 補完你判（資訊夠才定 override 覆蓋多廣）。
- **weaponsmith-demand fix（0aa7d3ae）維持 HELD** 直到 ① 重立因果（別在撤回的前提上 merge）。
